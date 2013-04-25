# based on the nicklist.pl script
use strict;
use IO::Handle;
use IO::Select;
use POSIX;
use File::Temp qw/ :mktemp  /;
use File::Basename;
use vars qw($VERSION %IRSSI);
$VERSION = '0.0.0';
%IRSSI = (
  authors     => 'Thiago de Arruda',
  contact     => 'tpadilha84@gmail.com',
  name        => 'tmux-nicklist',
  description => 'displays a list of nicks in a separate tmux pane',
  license     => 'WTFPL',
);

if ($#ARGV == -1) {
require Irssi;

my $enabled = 0;
my $script_path = __FILE__;
my $tmpdir;
my $fifo_path; 
# my $channel_pattern = '^&gtalk$';
my $channel_pattern = '^.+$';

sub enable_nicklist {
  return if ($enabled);
  $tmpdir = mkdtemp "/tmp/nicklist-XXXXXXXX";
  $fifo_path = "$tmpdir/fifo";
  POSIX::mkfifo($fifo_path, 0600) or die "can\'t mkfifo $fifo_path: $!";
  my $cmd = "perl $script_path $fifo_path $ENV{'TMUX_PANE'}";
  system('tmux', 'split-window', '-dh', '-p', '20', $cmd);
  # The next system call will block until the other pane has opened the pipe
  # for reading, so synchronization is not an issue here.
  open (FIFO, "> $fifo_path") or die "can't open $fifo_path: $!";
  FIFO->autoflush(1);
  $enabled = 1;
}

sub disable_nicklist {
  return unless ($enabled);
  print(FIFO "EXIT\n");
  close FIFO;
  unlink $fifo_path;
  rmdir $tmpdir;
  $enabled = 0;
}

sub reset_nicklist {
  my $active = Irssi::active_win();
  my $channel = $active->{active};

  if ((!$channel ||
      (ref($channel) ne 'Irssi::Irc::Channel' && ref($channel) ne
        'Irssi::Silc::Channel') || $channel->{'type'} ne 'CHANNEL' ||
      ($channel->{chat_type} ne 'SILC' && !$channel->{'names_got'})) ||
    ($channel->{'name'} !~ /$channel_pattern/ )) {
    disable_nicklist;
  } else {
    enable_nicklist;
    print(FIFO "BEGIN\n");
    foreach my $nick (sort {(($a->{'op'}?'1':$a->{'halfop'}?'2':$a->{'voice'}?'3':'4').lc($a->{'nick'}))
      cmp (($b->{'op'}?'1':$b->{'halfop'}?'2':$b->{'voice'}?'3':'4').lc($b->{'nick'}))} $channel->nicks()) {
      print(FIFO "NICK");
      if ($nick->{'op'}) {
        print(FIFO "\e[32m\@$nick->{'nick'}\e[39m");
      } elsif ($nick->{'halfop'}) {
        print(FIFO "\e[34m%$nick->{'nick'}\e[39m");
      } elsif ($nick->{'voice'}) {
        print(FIFO "\e[33m+$nick->{'nick'}\e[39m");
      } else {
        print(FIFO " $nick->{'nick'}");
      }
      print(FIFO "\n");
    }
    print(FIFO "END\n");
  }
}

Irssi::signal_add_last('window item changed', \&reset_nicklist);
Irssi::signal_add_last('window changed', \&reset_nicklist);
Irssi::signal_add_last('channel wholist', \&reset_nicklist);
# first, to be before ignores
Irssi::signal_add_first('message join', \&reset_nicklist);
Irssi::signal_add_first('message part', \&reset_nicklist);
Irssi::signal_add_first('message kick', \&reset_nicklist);
Irssi::signal_add_first('message quit', \&reset_nicklist);
Irssi::signal_add_first('message nick', \&reset_nicklist);
Irssi::signal_add_first('message own_nick', \&reset_nicklist);
Irssi::signal_add_first('nick mode changed', \&reset_nicklist);
Irssi::signal_add('gui exit', \&disable_nicklist);

} else {
require 'sys/ioctl.ph';
# open STDERR, '>', "$ENV{'HOME'}/.nickbar-errors.log";
my $fifo_path = $ARGV[0];
my $irssi_pane = $ARGV[1];
print(STDERR "PANE: $irssi_pane");
# array to store the current channel nicknames
my @nicknames = ();

# helper functions for manipulating the terminal
# escape sequences taken from
# http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x361.html
sub clear_screen { print "\e[2J"; }
sub save_cursor { print "\e[s"; }
sub restore_cursor { print "\e[u"; }
sub enable_mouse { print "\e[?1000h"; }
# recognized sequences
my $MOUSE_SCROLL_DOWN="27;91;77;97;";
my $MOUSE_SCROLL_UP="27;91;77;96;";
my $ARROW_DOWN="27;91;66;";
my $ARROW_UP="27;91;65;";
my $UP="107;";
my $DOWN="106;";
my $PAGE_DOWN="27;91;54;";
my $PAGE_UP="27;91;53;";
my $GO_TOP="103;103;";
my $GO_BOTTOM="71;";

my $current_line = 0;
my $sequence = '';

sub term_row_count {
  # from http://stackoverflow.com/questions/4286158/how-do-i-get-width-and-height-of-my-terminal-with-ioctl
  my $terminal_size;
  ioctl(STDOUT, TIOCGWINSZ() , $terminal_size);
  my ($rows, $cols, $xpix, $ypix) = unpack 'S4', $terminal_size;
  return $rows;
}

sub redraw {
  my $rows = term_row_count;
  my $last_nick_idx = $#nicknames - 1;
  my $last_idx = $current_line + $rows;
  # normalize last visible index
  if ($last_idx > ($last_nick_idx)) {
    $last_idx = $last_nick_idx;
  }
  # redraw visible nicks
  restore_cursor;
  clear_screen;
  for (my $idx = $current_line; $idx < $last_idx; $idx++) {
    print "$nicknames[$idx]\n";
  }
}

sub move_down {
  $sequence = '';
  my $count = $_[0];
  my $nickcount = $#nicknames;
  my $rows = term_row_count;
  return if ($nickcount <= $rows);
  if ($count == -1) {
    $current_line = $nickcount - $rows - 1;
    redraw;
    return;
  }
  my $visible = $nickcount - $current_line - $count;
  if ($visible > $rows) {
    $current_line += $count;
    redraw;
  } elsif (($visible + $count) > $rows) {
    # scroll the maximum we can
    $current_line = $nickcount - $rows - 1;
    redraw;
  }
}

sub move_up {
  $sequence = '';
  my $count = $_[0];
  if ($count == -1) {
    $current_line = 0;
    redraw;
    return;
  }
  return if ($current_line == 0);
  if (($current_line - $count) >= 0) {
    $current_line -= $count;
    redraw;
  }
}

# setup terminal so we can listen for individual key presses without echo
my ($term, $oterm, $echo, $noecho, $fd_stdin);
$fd_stdin = fileno(STDIN);
$term = POSIX::Termios->new();
$term->getattr($fd_stdin);
$oterm = $term->getlflag();
$echo = ECHO | ECHOK | ICANON;
$noecho = $oterm & ~$echo;
$term->setlflag($noecho);
$term->setcc(VTIME, 1);
$term->setattr($fd_stdin, TCSANOW);

# open named pipe and setup the 'select' wrapper object for listening on both
# fds(fifo and sdtin)
open (FIFO, "< $fifo_path") or die "can't open $fifo_path: $!";
my $fifo = \*FIFO;
my $stdin = \*STDIN;
my $select = IO::Select->new();
my @ready;
$select->add($fifo);
$select->add($stdin);

save_cursor;
enable_mouse;
system('tput', 'civis');
MAIN: {
  while (@ready = $select->can_read) {
    foreach my $fd (@ready) {
      if ($fd == $fifo) {
        while (<$fifo>) {
          my $line = $_;
          if ($line =~ /^BEGIN/) {
            @nicknames = ();
          } elsif ($line =~ /^NICK(.+)$/) {
            push @nicknames, $1;
          } elsif ($line =~ /^END$/) {
            redraw;
            last; 
          } elsif ($line =~ /^EXIT$/) {
            last MAIN;
          }
        }
      } else {
        my $key = '';
        sysread(STDIN, $key, 1);
        $key = ord($key);
        $sequence .= "$key;";
        if ($MOUSE_SCROLL_DOWN =~ /^$sequence/) {
          move_down 3 if ($MOUSE_SCROLL_DOWN eq $sequence);
        } elsif ($MOUSE_SCROLL_UP =~ /^$sequence/) {
          move_up 3 if ($MOUSE_SCROLL_UP eq $sequence);
        } elsif ($ARROW_DOWN =~ /^$sequence/) {
          move_down 1 if ($ARROW_DOWN eq $sequence);
        } elsif ($ARROW_UP =~ /^$sequence/) {
          move_up 1 if ($ARROW_UP eq $sequence);
        } elsif ($DOWN =~ /^$sequence/) {
          move_down 1 if ($DOWN eq $sequence);
        } elsif ($UP =~ /^$sequence/) {
          move_up 1 if ($UP eq $sequence);
        } elsif ($PAGE_DOWN =~ /^$sequence/) {
          move_down 20 if ($PAGE_DOWN eq $sequence);
        } elsif ($PAGE_UP =~ /^$sequence/) {
          move_up 20 if ($PAGE_UP eq $sequence);
        } elsif ($GO_BOTTOM =~ /^$sequence/) {
          move_down -1 if ($GO_BOTTOM eq $sequence);
        } elsif ($GO_TOP =~ /^$sequence/) {
          move_up -1 if ($GO_TOP eq $sequence);
        } else {
          # Unrecognized sequence, send to irssi
          # system('tmux', 'send-keys', '-l', '-t', $irssi_pane, $sequence);
          # system('tmux', 'select-pane', '-t', $irssi_pane);
          $sequence = '';
        }
      }
    }
  }
}

close FIFO;

}

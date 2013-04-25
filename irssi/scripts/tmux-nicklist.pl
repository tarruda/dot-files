# based on the nicklist.pl script
use strict;
use IO::Handle;
use IO::Select;
use POSIX;
use File::Temp qw/ :mktemp  /;
use File::Basename;
use vars qw($VERSION %IRSSI);
$VERSION = '0.4.6';
%IRSSI = (
  authors     => 'Thiago de Arruda',
  contact     => 'tpadilha84@gmail.com',
  name        => 'tmux-nicklist',
  description => 'displays a list of nicks in a separate tmux pane',
  license     => 'GPLv2',
);

if ($#ARGV == -1) {
require Irssi;

my $enabled = 0;
my $script_path = __FILE__;
my $tmpdir;
my $fifo_path; 
my $channel_pattern = '&gtalk';

sub enable_nicklist {
  return if ($enabled);
  $tmpdir = mkdtemp "/tmp/nicklist-XXXXXXXX";
  $fifo_path = "$tmpdir/fifo";
  POSIX::mkfifo($fifo_path, 0600) or die "can\'t mkfifo $fifo_path: $!";
  my $cmd = "perl $script_path $fifo_path";
  system('tmux', 'split-window', '-dh', '-l', '18', $cmd);
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
    ($channel->{'name'} !~ /^$channel_pattern$/ )) {
    disable_nicklist;
  } else {
    enable_nicklist;
    print(FIFO "RESET\n");
    foreach my $nick (sort {(($a->{'op'}?'1':$a->{'halfop'}?'2':$a->{'voice'}?'3':'4').lc($a->{'nick'}))
      cmp (($b->{'op'}?'1':$b->{'halfop'}?'2':$b->{'voice'}?'3':'4').lc($b->{'nick'}))} $channel->nicks()) {

      print(FIFO "APPEND");
      print(FIFO "$nick->{'nick'};");
      if ($nick->{'op'}) {
        print(FIFO "op");
      } elsif ($nick->{'halfop'}) {
        print(FIFO "halfop");
      } elsif ($nick->{'voice'}) {
        print(FIFO "voice");
      } else {
        print(FIFO "normal");
      }
      print(FIFO "\n");
    }
    print(FIFO "ENDPAYLOAD\n");
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

my $fifo_path = $ARGV[0];
# array to store the current channel nicknames
my @nicknames = ();

# helper functions for manipulating the terminal
# escape sequences taken from
# http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x361.html
sub clear_screen { print "\e[2J"; }
sub save_cursor { print "\e[s"; }
sub restore_cursor { print "\e[u"; }
sub enable_mouse { print "\e[?1000h"; }
sub disable_mouse { print "\e[?1000l"; }

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
enable_mouse; # also disables tmux scrolling for the pane
MAIN: {
  while (@ready = $select->can_read) {
    foreach my $fd (@ready) {
      if ($fd == $fifo) {
        while (<$fifo>) {
          my $line = $_;
          if ($line =~ /^RESET/) {
            restore_cursor;
            clear_screen;
          } elsif ($line =~ /^APPEND(.+)$/) {
            my ($nick, $mode) = split(/;/, $1);
            if ($mode =~ 'op') {
              print "\e[32m\@$nick\e[39m\n";
            } elsif ($mode =~ 'halfop') {
              print "\e[34m%$nick\e[39m\n";
            } elsif ($mode =~ 'voice') {
              print "\e[33m+$nick\e[39m\n";
            } else {
              print " $nick\n"; 
            }
          } elsif ($line =~ /^ENDPAYLOAD$/) {
            last; 
          } elsif ($line =~ /^EXIT$/) {
            last MAIN;
          }
        }
      } else {
        my $key = '';
        sysread(STDIN, $key, 1);
        # TODO handle mouse scroll
      }
    }
  }
}

close FIFO;

}

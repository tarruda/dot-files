use strict;
use POSIX qw /mkfifo/;
use IO::Handle;
use IO::Select;
use Term::ReadKey;
use File::Temp qw/ :mktemp  /;
use Data::Dumper;
use File::Basename;

if ($#ARGV == -1) {

require Irssi;
use vars qw($VERSION %IRSSI);
$VERSION = '0.4.6';
%IRSSI = (
  authors     => 'Thiago de Arruda',
  contact     => 'tpadilha84@gmail.com',
  name        => 'tmux-nicklist',
  description => 'displays a list of nicks in a separate tmux pane',
  license     => 'GPLv2',
);

# temporary directory for this session
my $tmpdir = mkdtemp "/tmp/nicklist-XXXXXXXX";
my $fifo_path = "$tmpdir/fifo"; 
my $script_path = __FILE__;
my $active_channel;
my @nicklist;
# nick => realnick
# mode =>
my ($MODE_OP, $MODE_HALFOP, $MODE_VOICE, $MODE_NORMAL) = (0,1,2,3);
# status =>
my ($STATUS_NORMAL, $STATUS_JOINING, $STATUS_PARTING, $STATUS_QUITING, $STATUS_KICKED, $STATUS_SPLIT) = (0,1,2,3,4,5);
# text => text to be printed
# cmp => text used to compare (sort) nicks


# starts the nicklist process in the split pane
sub start_nicklist {
  # create the named fifo for this session
  if (-e $fifo_path) {
    unlink $fifo_path;
  }
  mkfifo($fifo_path, 0600) or die "can\'t mkfifo $fifo_path: $!";
  my $cmd = "perl $script_path $fifo_path";
  system('tmux', 'split-window', '-dh', '-l', '18', $cmd);
  # this will block until the other pane has opened the pipe for reading,
  # so synchronization is not an issue
  open (FIFO, "> $fifo_path") or die "can't open $fifo_path: $!";
  FIFO->autoflush(1);
  print(FIFO "1\n");
  sleep 2;
  print(FIFO "2\n");
  sleep 2;
  print(FIFO "3\n");
  sleep 2;
  print(FIFO "4\n");
  sleep 2;

}

sub nicklist_write_line {
  my ($line, $data) = @_;
  print(FIFO $data);
}

# make the (internal) nicklist (@nicklist)
sub make_nicklist {
  @nicklist = ();

  ### get & check channel ###
  my $channel = Irssi->active_win->{active};

  if (!$channel || (ref($channel) ne 'Irssi::Irc::Channel' && ref($channel) ne 'Irssi::Silc::Channel') || $channel->{'type'} ne 'CHANNEL' || ($channel->{chat_type} ne 'SILC' && !$channel->{'names_got'}) ) {
    $active_channel = undef;
    # no nicklist
  } else {
    $active_channel = $channel;
    ### make nicklist ###
    my $thisnick;
    foreach my $nick (sort {(($a->{'op'}?'1':$a->{'halfop'}?'2':$a->{'voice'}?'3':'4').lc($a->{'nick'}))
      cmp (($b->{'op'}?'1':$b->{'halfop'}?'2':$b->{'voice'}?'3':'4').lc($b->{'nick'}))} $channel->nicks()) {
      $thisnick = {'nick' => $nick->{'nick'}, 'mode' => ($nick->{'op'}?$MODE_OP:$nick->{'halfop'}?$MODE_HALFOP:$nick->{'voice'}?$MODE_VOICE:$MODE_NORMAL)};
      push @nicklist, $thisnick;
    }
  }
}

# insert nick(as hash) into nicklist
# pre: cmp has to be calculated
sub insert_nick {
  my ($nick) = @_;
  my $nr = find_insert_pos($nick->{'cmp'});
  splice @nicklist, $nr, 0, $nick;
  draw_insert_nick_nr($nr);
}

# remove nick(as nr) from nicklist
sub remove_nick {
  my ($nr) = @_;
  splice @nicklist, $nr, 1;
}

sub sig_join {
  my ($server,$channel,$nick,$address) = @_;
  if (!is_active_channel($server,$channel)) {
    return;
  }
  my $newnick = {'nick' => $nick, 'mode' => $MODE_NORMAL};
  insert_nick($newnick);
}

sub sig_kick {
  my ($server, $channel, $nick, $kicker, $address, $reason) = @_;
  if (!is_active_channel($server,$channel)) {
    return;
  }
  my $nr = find_nick($nick);
  if ($nr == -1) {
    Irssi::print("nicklist warning: $nick was kicked from $channel, but not found in nicklist");
  } else {
    remove_nick($nr);
  }
}

sub sig_part {
  my ($server,$channel,$nick,$address, $reason) = @_;
  if (!is_active_channel($server,$channel)) {
    return;
  }
  my $nr = find_nick($nick);
  if ($nr == -1) {
    Irssi::print("nicklist warning: $nick has parted $channel, but was not found in nicklist");
  } else {
    remove_nick($nr);
  }

}

sub sig_quit {
  my ($server,$nick,$address, $reason) = @_;
  if ($server->{'tag'} ne $active_channel->{'server'}->{'tag'}) {
    return;
  }
  my $nr = find_nick($nick);
  if ($nr != -1) {
    remove_nick($nr);
  }
}

sub sig_nick {
  my ($server, $newnick, $oldnick, $address) = @_;
  if ($server->{'tag'} ne $active_channel->{'server'}->{'tag'}) {
    return;
  }
  my $nr = find_nick($oldnick);
  if ($nr != -1) { # if nick was found (nickchange is in current channel)
    my $nick = $nicklist[$nr];
    remove_nick($nr);
    $nick->{'nick'} = $newnick;
    insert_nick($nick);
  }
}

sub sig_mode {
  my ($channel, $nick, $setby, $mode, $type) = @_; # (nick and channel as rec)
  if ($channel->{'server'}->{'tag'} ne $active_channel->{'server'}->{'tag'} || $channel->{'name'} ne $active_channel->{'name'}) {
    return;
  }
  my $nr = find_nick($nick->{'nick'});
  if ($nr == -1) {
    Irssi::print("nicklist warning: $nick->{'nick'} had mode set on $channel->{'name'}, but was not found in nicklist");
  } else {
    my $nicklist_item = $nicklist[$nr];
    remove_nick($nr);
    $nicklist_item->{'mode'} = ($nick->{'op'}?$MODE_OP:$nick->{'halfop'}?$MODE_HALFOP:$nick->{'voice'}?$MODE_VOICE:$MODE_NORMAL);
    insert_nick($nicklist_item);
  }
}

##### command binds #####
# Irssi::command_bind 'nicklist' => sub {
#   my ( $data, $server, $item ) = @_;
#   $data =~ s/\s+$//g;
#   Irssi::command_runsub ('nicklist', $data, $server, $item ) ;
# };
# Irssi::signal_add_first 'default command nicklist' => sub {
#   # gets triggered if called with unknown subcommand
# };

##### signals #####
# Irssi::signal_add_last('window item changed', \&make_nicklist);
# Irssi::signal_add_last('window changed', \&make_nicklist);
# Irssi::signal_add_last('channel wholist', \&sig_channel_wholist);
# Irssi::signal_add_first('message join', \&sig_join); # first, to be before ignores
# Irssi::signal_add_first('message part', \&sig_part);
# Irssi::signal_add_first('message kick', \&sig_kick);
# Irssi::signal_add_first('message quit', \&sig_quit);
# Irssi::signal_add_first('message nick', \&sig_nick);
# Irssi::signal_add_first('message own_nick', \&sig_nick);
# Irssi::signal_add_first('nick mode changed', \&sig_mode);

start_nicklist;
# open_fifo;

} else {

my $fifo_path = $ARGV[0];
open (FIFO, "< $fifo_path") or die "can't open $fifo_path: $!";

my $fifo = \*FIFO;
my $stdin = \*STDIN;

my $select = IO::Select->new();
$select->add($fifo);
$select->add($stdin);

ReadMode 4;

my @ready;

LOOP: {
  while (@ready = $select->can_read) {
    foreach my $fd (@ready) {
      if ($fd == $fifo) {
        my $line = ReadLine 0, $fifo;
        unless ($line) {
          last LOOP;
        }
        print $line;
      } else {
        my $key = ReadKey(-1);
        print "Get key $key\n";
      }
    }
  }
}

ReadMode 0;
close FIFO;

}

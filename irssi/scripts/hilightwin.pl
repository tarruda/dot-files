# Print hilighted messages & private messages to window named "hilight" for
# irssi 0.7.99 by Timo Sirainen
#
# Modded a tiny bit by znx to stop private messages entering the hilighted
# window (can be toggled) and to put up a timestamp.
#
# Modded by tarruda to keep a permanent 'tail log' of the window across
# irssi restarts.

use Irssi;
use POSIX;
use Fcntl qw( :seek O_RDONLY );
use vars qw($VERSION %IRSSI); 

$VERSION = "0.03";
%IRSSI = (
    authors     => "Timo \'cras\' Sirainen, Mark \'znx\' Sangster, Thiago de Arruda",
    contact     => "tss\@iki.fi, znxster\@gmail.com tpadilha84\@gmail.com", 
    name        => "hilightwin",
    description => "Print hilighted messages to window named \"hilight\"",
    license     => "Public Domain",
    url         => "http://irssi.org/",
    changed     => "Sun May 25 18:59:57 BST 2008"
);

Irssi::settings_add_bool('hilightwin', 'hilightwin_showprivmsg', 1);
Irssi::settings_add_bool('hilightwin', 'hilightwin_enable_log', 1);
Irssi::settings_add_int('hilightwin', 'hilightwin_log_tail_count', 50);
Irssi::settings_add_str('hilightwin', 'hilightwin_log_file', "$ENV{'HOME'}/.irssi-hilightwin.log");
Irssi::settings_add_str('hilightwin', 'hilightwin_timestamp_format', "%Y-%m-%d %H:%M ");

my $enable_log = Irssi::settings_get_bool('hilightwin_enable_log');
my $logfile = Irssi::settings_get_str('hilightwin_log_file');

sub sig_printtext {
    my ($dest, $text, $stripped) = @_;

    my $opt = MSGLEVEL_HILIGHT;

    if(Irssi::settings_get_bool('hilightwin_showprivmsg')) {
        $opt = MSGLEVEL_HILIGHT|MSGLEVEL_MSGS;
    }
    
    if(
        ($dest->{level} & ($opt)) &&
        ($dest->{level} & MSGLEVEL_NOHILIGHT) == 0
    ) {
        $window = Irssi::window_find_name('hilight');
        
        if ($dest->{level} & MSGLEVEL_PUBLIC) {
            $text = $dest->{target}.": ".$text;
        }
        $text = strftime(Irssi::settings_get_str('hilightwin_timestamp_format'), localtime).$text;
        $window->print($text, MSGLEVEL_NEVER) if ($window);
        print(LOGFILE "\0$text") if $enable_log;
    }
}

my $win = Irssi::window_find_name('hilight');

if (-r $logfile && $win && $enable_log) {
  # read the last n entries in the logfile and print it to the window, where n
  # is 'hilightwin_previous_entries'
  my @entries = ();
  my $max_entries = Irssi::settings_get_int('hilightwin_log_tail_count');
  my $block_size = 4096;
  my $buffer = '';
  my (@entry_buffer, $read_buffer, $pos, $last_read_pos, $partial_entry);

  # reading backwards is better done with sysopen/sysread/sysseek so we can
  # scale to big log files
  sysopen(LOGFILE, $logfile, O_RDONLY);

  # file must be read using bytes as units instead of characters since we use
  # the 0 byte to mark an entry boundary(which can contain multiple lines) 
  binmode $LOGFILE;

  # go the beginning of the first block
  $pos = sysseek(LOGFILE, -$block_size, SEEK_END);
  if (!$pos) {
    # only one read will be needed
    $pos = sysseek(LOGFILE, 0, SEEK_SET);
  }

  while ($#entries < $max_entries && $last_read_pos ne "0 but true") {

    # read the block and append to the buffer
    sysread(LOGFILE, $read_buffer, $block_size);
    $buffer = "$read_buffer$buffer";

    # split the entries read in the last block
    @entry_buffer = split("\0", $buffer);

    $partial_entry = shift(@entry_buffer);
    if ($partial_entry ne '') {
      # incomplete entry, keep it in the buffer so it will be
      # appended to the next read
      $buffer = $partial_entry;
    } else {
      # reset the buffer
      $buffer = '';
    }

    # unshift entries read in this block to other entries read
    @entries = (@entry_buffer, @entries);

    # mark the last read position
    $last_read_pos = $pos;

    # rewind to reset the position to before the read
    sysseek(LOGFILE, -$block_size, SEEK_CUR);

    # rewind to the next block
    $pos = sysseek(LOGFILE, -$block_size, SEEK_CUR);

    if (!$pos) {
      # failure here means we tried to rewind past the beggining of file
      $pos = sysseek(LOGFILE, 0, SEEK_SET);
    }
  }

  close(LOGFILE);
  
  # remove any unwanted entries
  shift(@entries) while ($#entries >= $max_entries);

  foreach my $entry (@entries) {
    $win->print($entry, MSGLEVEL_NEVER);
  }
}

if ($enable_log) {
  open (LOGFILE, ">> $logfile");
  LOGFILE->autoflush(1);
}

Irssi::signal_add('print text', 'sig_printtext');

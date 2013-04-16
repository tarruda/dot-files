use strict;

use vars qw($VERSION %IRSSI);
use Irssi qw(command_bind signal_add);

$VERSION = '0.01';
%IRSSI = (
  authors     => 'Thiago de Arruda',
  contact     => 'tpadilha84@gmail.com',
  name        => 'Passwords',
  description => 'Loads passwords from a textfile ' .
                 'and authenticates automatically ' .
                 'when the server requests.',
  license     => 'WTFPL',
);

my %passwords;
my $register_request = 'This nickname is registered.';
my $nickserv_nick = 'NickServ';
my $ns_hosts = 'NickServ@services.';

sub process_server_msg {
  my ($server, $data, $nickname, $hostname) = @_;

  my ($target, $text) = $data =~ /^(\S*)\s:(.*)/;

  return if ($target !~ /$server->{nick}/);

  return if ($text !~ /$register_request/i) || ($nickname !~ /$nickserv_nick/);

  if ($hostname !~ $ns_hosts) {
    print("!!!'$nickname($hostname)' trying to cause nickserv authentication, but " .
      "the host is not recognized as a valid nickserv host!!!", MSGLEVEL_CRAP);
    return;
  }

  my $chatnet = $server->{'chatnet'};

  if (exists($passwords{$chatnet})) {
    print("Authenticating '$server->{nick}' on '$chatnet'");
    $server->command("msg $nickserv_nick identify " . $passwords{$chatnet});
  }
}

sub reload_passwords {
  %passwords = ();
  open PASSWORDS_DB, "$ENV{'HOME'}/.irssi-passwords";
  while (<PASSWORDS_DB>) {
    chomp;
    my ($chatnet, $password) = split(':');
    $passwords{$chatnet} = $password;
  }
  close PASSWORDS_DB
}

reload_passwords;

signal_add 'event notice', 'process_server_msg';

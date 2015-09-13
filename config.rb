module Laura
  class Config
    Connection = {
      'server' => 'irc.euirc.net',
      'port' => 6667,
      'channels' => ['#laura_dev'],
      'connect_timeout' => 10,
      'read_timeout' => 240,
    }
    User = {
      'nick' => 'laura_',
      'username' => 'laurabot',
      'realname' => 'laurabot',
      'password' => '',
    }
    Imouto = {
      'message_interval_size' => 4,
      'messages_per_interval' => 3,
      'loggers' => [lambda {|msg| p msg}] 
    }
    Laura = {
      'master' => 'zwdr!~lain@zwdr.euirc.net',
      'prefix' => '\+',
      'plugins' => ['Echo', 'Rate', 'Admin', 'Poll'],
      'escape_chars' => ['!', ',', '+']
    }
  end
end
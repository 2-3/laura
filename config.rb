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
    Laura = {
      'master' => 'zwdr!~lain@zwdr.euirc.net',
      'prefix' => '\+',
      'plugins' => ['Echo', 'Rate', 'Admin'],
      'escape_chars' => ['!', ',', '+']
    }
  end
end
# -*- coding: utf-8 -*-
require 'kconv'

class Platform
  def self.windows_os?
    RUBY_PLATFORM =~ /mswin(?!ce)|mingw|cygwin|bccwin/
  end

  def self.get_shell_kcode
    if windows_os?
      Kconv::SJIS
    else
      Kconv::UTF8
    end
  end
end

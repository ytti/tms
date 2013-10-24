module TMS
  class Mail
    require 'net/smtp'

    def alarm msg
      from = CFG.email['from']
      to   = [CFG.email['to']].flatten.join(', ')
      mail  = []
      mail << 'From: '    + from
      mail << 'To: '      + to
      mail << 'Subject: ' + msg
      mail << 'List-Id: "Trivial Monitoring System alarms <tms.lan.nms.fi.tdc.net>"'
      mail << 'X-Mailer: tms-mail'
      mail << ''

      Net::SMTP.start('localhost') do |smtp|
        smtp.send_message mail.join("\n"), from, [CFG.email['to']].flatten
      end
    end
  end
end

Get-Content ".\mail.conf" | Where-Object {$_.length -gt 0} | Where-Object {!$_.StartsWith("#")} | ForEach-Object {

    $var = $_.Split('=',2).Trim()
    if (Get-Variable -Name $var[0] -ErrorAction SilentlyContinue) {
      Set-Variable -Scope Script -Name $var[0] -Value $var[1]
    } else {
      New-Variable -Scope Script -Name $var[0] -Value $var[1]
    }

}


$emailSecurePass = ConvertTo-SecureString -String $emailPlainPass -AsPlainText -Force

$cred = New-Object System.Management.Automation.PSCredential ($emailSmtpUser, $emailSecurePass)

$UsersList = Import-Csv -Delimiter "|" -Path $mail_list




FOREACH ($Person in $UsersList) {
  
  
  $emailTo = $Person.email
  $fio = $Person.fio
  $teams_login = $Person.login + "@pku.petrpku.ru"
  $pass_phrase = $Person.password
  
  
  echo "sending email to $fio $emailTo"
  
  $mail_template_ready = [IO.File]::ReadAllText($mail_template)
  #Read-Host -Prompt "Press Enter to continue"
  $mail_body = Invoke-Expression """$mail_template_ready"""  
  
    
  #Write-Host $mail_body
     
  
  Send-MailMessage -SmtpServer $emailSmtpServer -Credential $cred -UseSsl -From $emailFrom -To $emailTo -Subject $mail_subject -Body $mail_body -Attachments $attachment -Encoding "UTF8"

}
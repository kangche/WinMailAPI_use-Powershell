 function md5($String)
    {
        $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
        $utf8 = New-Object -TypeName System.Text.UTF8Encoding
        $hash = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($String)))
        $Format_hash=$hash.Replace("-",'').ToLower()
        return $Format_hash
    }
#获取MD5值函数

    function Get-Sessid($Apikeypass,$Apikey,$Apass,$Auser)
    {
        $timestamp = ((Get-Date -UFormat %s -Millisecond 0) - (8*3600))
        $method="login"
        $Login = @($apikeypass,$apikey,$method,$Apass,$timestamp,$Auser)
        #               0         1        2      3       4       5
        $signstring =  "{0}apikey{1}method{2}pass{3}timestamp{4}user{5}{0}" -f $Login
        $sign =  md5 -String $signstring
        $baseurl = 'http://mail.zillion.com/admin/openapi.php?apikey={1}&method={2}&pass={3}&timestamp={4}&user={5}&sign='-f $Login +$sign
        ((Invoke-WebRequest $baseurl).content | ConvertFrom-Json).info.sessid
    }

#获取管理员Sessid
function Add-MailUser($Apikeypass,$Apikey,$Department,$Fullname,$Ftpquota,$Mailquota,$Name,$Password) 
{
$domain='zillion-info.com'
$ftpquota = '0'  #网盘配额
$mailquota='2048'   #邮箱配额
$method='user.added'
$password='Zillion123456' # 默认账号密码
$timestamp = ((Get-Date -UFormat %s -Millisecond 0) - (8*3600))
$adduser=@($apikeypass,$apikey,$department,$domain,$fullname,$ftpquota,$mailquota,$method,$name,$password,$timestamp,$sessid)
#             0           1       2           3         4          5         6       7    8          9         10        11 
$sign2string = "{0}apikey{1}department{2}domain{3}ftpquota{5}fullname{4}mailquota{6}method{7}name{8}password{9}sessid{11}timestamp{10}{0}" -f $adduser
$sign2md5 = md5 -String $sign2string
$cbaseur3 = 'http://mail.zillion.com/admin/openapi.php?apikey={1}&department={2}&domain={3}&ftpquota={5}&fullname={4}&mailquota={6}&method={7}&name={8}&password={9}&sessid={11}&timestamp={10}&sign=' -f $adduser  +$sign2md5
Invoke-WebRequest $cbaseur3
}
#创建用户

$sessid = Get-sessid -Apikeypass $apikeypass -Apikey $apikey -Apass $pass -Auser $user
add-MailUser -Apikeypass $apikeypass -Apikey $apikey -Department $department -Fullname $fullname -Name $name

function List-Users($Apikeypass,$Apikey,$Sessid,$Pageno)
        {
            $domain = 'zillion-info.com' # 操作的邮箱域
            $timestamp = ((Get-Date -UFormat %s -Millisecond 0) - (8*3600))
            $method='user'
            $CheckUsers= @($apikeypass,$apikey,$domain,$method,$pageno,$sessid,$timestamp)
            #                  0          1       2       3       4        5         6    
            $sign1string = "{0}apikey{1}domain{2}method{3}pageno{4}sessid{5}timestamp{6}{0}" -f $CheckUsers
            $sign1 =  md5 -String $sign1string
            $cbaseurl1 = 'http://mail.zillion.com/admin/openapi.php?apikey={1}&domain={2}&method={3}&pageno={4}&sessid={5}&timestamp={6}&sign=' -f $CheckUsers  +$sign1
            $res=(Invoke-WebRequest $cbaseurl1).content
            return $res
        }




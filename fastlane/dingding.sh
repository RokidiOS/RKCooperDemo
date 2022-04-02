time=$(date "+%Y-%m-%d %H:%M:%S")
#version=$1

##项目群通知 
curl 'https://oapi.dingtalk.com/robot/send?access_token=713187eb6085be817a125683f90fe42f7c3d9c2c9b6ec6f0ae5fc01d10183834' \
    -H 'Content-Type: application/json' \
    -d '
{
    "msgtype": "markdown",
    "markdown": {
        "title":"打包上传到蒲公英",
        "text":"> ·iOS：RTC Demo 新包已发  \n > ·环境：Pro  \n > ·下载链接： https://www.pgyer.com/coreexample_ios  \n > ![](https://www.pgyer.com/app/qrcode/coreexample_ios)
        \n > **打包时间**： '"$time"'"
    }
}'

Xephyr  -ac -br -noreset -screen 800x600 :1 &
sleep 1;
DISPLAY=:1.0 awesome -c ./rc.lua > ./out.std 2>./out.err &
#DISPLAY=:1.0 awesome -c ./rc.lua &

ps -ef |grep "awesome -c"
tail -f out.err

sed -i \
    -e '/debug/s/=> .*/=> env("OCTOBER_APP_DEBUG", true)/' \
    -e '/url/s/=> .*/=> env("OCTOBER_APP_URL", "http://localhost")/' \ 
    -e '/timezone/s/=> .*/=> env("OCTOBER_APP_TIMEZONE", true)/' \
    app.php 
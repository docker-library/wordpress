<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Bleeding edge updates
    |--------------------------------------------------------------------------
    |
    | If you are developing with October, it is important to have the latest
    | code base, set this value to 'true' to tell the platform to download
    | and use the development copies of core files and plugins.
    |
    */

    'edgeUpdates' => getenv('OCTOBER_CMS_EDGE_UPDATES') ?: false,

    /*
    |--------------------------------------------------------------------------
    | Specifies the default CMS theme.
    |--------------------------------------------------------------------------
    |
    | This parameter value can be overridden by the CMS back-end settings.
    |
    */

    'activeTheme' => getenv('OCTOBER_CMS_ACTIVE_THEME') ?: 'demo',

    /*
    |--------------------------------------------------------------------------
    | Back-end URI prefix
    |--------------------------------------------------------------------------
    |
    | Specifies the URI prefix used for accessing back-end pages.
    |
    */

    'backendUri' => getenv('OCTOBER_CMS_BACKEND_URI') ?: 'backend',

    /*
    |--------------------------------------------------------------------------
    | Back-end Skin
    |--------------------------------------------------------------------------
    |
    | Specifies the back-end skin to use.
    |
    */

    'backendSkin' => 'Backend\Skins\Standard',

    /*
    |--------------------------------------------------------------------------
    | Determines which modules to load
    |--------------------------------------------------------------------------
    |
    | Specify which modules should be registered when using the application.
    |
    */

    'loadModules' => ['System', 'Backend', 'Cms'],

    /*
    |--------------------------------------------------------------------------
    | Prevents application updates
    |--------------------------------------------------------------------------
    |
    | If using composer or git to download updates to the core files, set this
    | value to 'true' to prevent the update gateway from trying to download
    | these files again as part of the application update process. Plugins
    | and themes will still be downloaded.
    |
    */

    'disableCoreUpdates' => getenv('OCTOBER_CMS_DISABLE_CORE_UPDATES') ?: false,

    /*
    |--------------------------------------------------------------------------
    | Specific plugins to disable
    |--------------------------------------------------------------------------
    |
    | Specify plugin codes which will always be disabled in the application.
    |
    */

    'disablePlugins' => [],

    /*
    |--------------------------------------------------------------------------
    | Determines if the routing caching is enabled.
    |--------------------------------------------------------------------------
    |
    | If the caching is enabled, the page URL map is saved in the cache. If a page
    | URL was changed on the disk, the old URL value could be still saved in the cache.
    | To update the cache the back-end Clear Cache feature should be used. It is recommended
    | to disable the caching during the development, and enable it in the production mode.
    |
    */

    'enableRoutesCache' => getenv('OCTOBER_CMS_ENABLE_ROUTES_CACHE') ?: false,

    /*
    |--------------------------------------------------------------------------
    | Time to live for the URL map.
    |--------------------------------------------------------------------------
    |
    | The URL map used in the CMS page routing process. By default
    | the map is updated every time when a page is saved in the back-end or when the
    | interval, in minutes, specified with the urlMapCacheTTL parameter expires.
    |
    */

    'urlCacheTtl' => getenv('OCTOBER_CMS_URL_CACHE_TTL') ?: 10,

    /*
    |--------------------------------------------------------------------------
    | Time to live for parsed CMS objects.
    |--------------------------------------------------------------------------
    |
    | Specifies the number of minutes the CMS object cache lives. After the interval
    | is expired item are re-cached. Note that items are re-cached automatically when
    | the corresponding template file is modified.
    |
    */

    'parsedPageCacheTTL' => getenv('OCTOBER_CMS_PARSED_PAGE_CACHE_TTL') ?:  10,

    /*
    |--------------------------------------------------------------------------
    | Determines if the asset caching is enabled.
    |--------------------------------------------------------------------------
    |
    | If the caching is enabled, combined assets are cached. If a asset file
    | is changed on the disk, the old file contents could be still saved in the cache.
    | To update the cache the back-end Clear Cache feature should be used. It is recommended
    | to disable the caching during the development, and enable it in the production mode.
    |
    */

    'enableAssetCache' => getenv('OCTOBER_CMS_ENABLE_ASSET_CACHE') ?: false,

    /*
    |--------------------------------------------------------------------------
    | Determines if the asset minification is enabled.
    |--------------------------------------------------------------------------
    |
    | If the minification is enabled, combined assets are compressed (minified).
    | It is recommended to disable the minification during development, and
    | enable it in production mode. If set to null, assets are minified
    | when debug mode (app.debug) is disabled.
    |
    */

    'enableAssetMinify' => getenv('OCTOBER_CMS_ENABLE_ASSET_MINIFY') ?: null,

    /*
    |--------------------------------------------------------------------------
    | Public plugins path
    |--------------------------------------------------------------------------
    |
    | Specifies the public plugins path relative to the application base URL,
    | or you can specify a full URL path.
    |
    */

    'pluginsPath' => '/plugins',

    /*
    |--------------------------------------------------------------------------
    | Public themes path
    |--------------------------------------------------------------------------
    |
    | Specifies the public themes path relative to the application base URL,
    | or you can specify a full URL path.
    |
    */

    'themesPath' => '/themes',

    /*
    |--------------------------------------------------------------------------
    | Resource storage
    |--------------------------------------------------------------------------
    |
    | Specifies the configuration for resource storage, such as media and
    | upload files. These resources are used:
    |
    | media   - generated by the media manager.
    | uploads - generated by attachment model relationships.
    |
    | For each resource you can specify:
    |
    | disk   - filesystem disk, as specified in filesystems.php config.
    | folder - a folder prefix for storing all generated files inside.
    | path   - the public path relative to the application base URL,
    |          or you can specify a full URL path.
    */

    'storage' => [

        'uploads' => [
            'disk'   => getenv('OCTOBER_CMS_STORAGE_UPLOADS_DISK') ?: 'local',
            'folder' => getenv('OCTOBER_CMS_STORAGE_UPLOADS_FOLDER') ?: 'uploads',
            'path'   => getenv('OCTOBER_CMS_STORAGE_UPLOADS_PATH') ?: '/storage/app/uploads',
        ],

        'media' => [
            'disk'   => getenv('OCTOBER_CMS_STORAGE_MEDIA_DISK') ?: 'local',
            'folder' => getenv('OCTOBER_CMS_STORAGE_MEDIA_FOLDER') ?: 'media',
            'path'   => getenv('OCTOBER_CMS_STORAGE_MEDIA_PATH') ?: '/storage/app/media',
        ],

    ],

    /*
    |--------------------------------------------------------------------------
    | Convert Line Endings
    |--------------------------------------------------------------------------
    |
    | Determines if October should convert line endings from the windows style
    | \r\n to the unix style \n.
    |
    */

    'convertLineEndings' => getenv('OCTOBER_CMS_CONVERT_LINE_ENDINGS') ?: false,

    /*
    |--------------------------------------------------------------------------
    | Linking policy
    |--------------------------------------------------------------------------
    |
    | Controls how URL links are generated throughout the application.
    |
    | detect   - detect hostname and use the current schema
    | secure   - detect hostname and force HTTPS schema
    | insecure - detect hostname and force HTTP schema
    | force    - force hostname and schema using app.url config value
    |
    */

    'linkPolicy' => getenv('OCTOBER_CMS_LINK_POLICY') ?: 'detect',

    /*
    |--------------------------------------------------------------------------
    | Default permission mask
    |--------------------------------------------------------------------------
    |
    | Specifies a default file and folder permission for newly created objects.
    |
    */

    'defaultMask' => ['file' => null, 'folder' => null],

    /*
    |--------------------------------------------------------------------------
    | Cross Site Request Forgery (CSRF) Protection
    |--------------------------------------------------------------------------
    |
    | If the CSRF protection is enabled, all "postback" requests are checked
    | for a valid security token.
    |
    */

    'enableCsrfProtection' => getenv('OCTOBER_CMS_ENABLE_CSRF_PROTECTION') ?: false,

];

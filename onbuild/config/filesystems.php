<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Default Filesystem Disk
    |--------------------------------------------------------------------------
    |
    | Here you may specify the default filesystem disk that should be used
    | by the framework. A "local" driver, as well as a variety of cloud
    | based drivers are available for your choosing. Just store away!
    |
    | Supported: "local", "s3", "rackspace"
    |
    */

    'default' => getenv('OCTOBER_FILESYSTEMS_DEFAULT') ?: 'local',

    /*
    |--------------------------------------------------------------------------
    | Default Cloud Filesystem Disk
    |--------------------------------------------------------------------------
    |
    | Many applications store files both locally and in the cloud. For this
    | reason, you may specify a default "cloud" driver here. This driver
    | will be bound as the Cloud disk implementation in the container.
    |
    */

    'cloud' => getenv('OCTOBER_FILESYSTEMS_CLOUD') ?: 's3',

    /*
    |--------------------------------------------------------------------------
    | Filesystem Disks
    |--------------------------------------------------------------------------
    |
    | Here you may configure as many filesystem "disks" as you wish, and you
    | may even configure multiple disks of the same driver. Defaults have
    | been setup for each driver as an example of the required options.
    |
    */

    'disks' => [

        'local' => [
            'driver' => 'local',
            'root'   => storage_path().'/app',
        ],

        's3' => [
            'driver' => 's3',
            'key'    => getenv('OCTOBER_FILESYSTEMS_DISKS_S3_KEY') ?: 'your-key',
            'secret' => getenv('OCTOBER_FILESYSTEMS_DISKS_S3_SECRET') ?: 'your-secret',
            'region' => getenv('OCTOBER_FILESYSTEMS_DISKS_S3_REGION') ?: 'your-region',
            'bucket' => getenv('OCTOBER_FILESYSTEMS_DISKS_S3_BUCKET') ?: 'your-bucket',
        ],

        'rackspace' => [
            'driver'    => 'rackspace',
            'username'  => getenv('OCTOBER_FILESYSTEMS_DISKS_RACKSPACE_USERNAME') ?: 'your-username',
            'key'       => getenv('OCTOBER_FILESYSTEMS_DISKS_RACKSPACE_KEY') ?: 'your-key',
            'container' => getenv('OCTOBER_FILESYSTEMS_DISKS_RACKSPACE_CONTAINER') ?: 'your-container',
            'endpoint'  => 'https://identity.api.rackspacecloud.com/v2.0/',
            'region'    => 'IAD',
        ],

    ],

];

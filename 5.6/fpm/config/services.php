<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Stripe, Mailgun, Mandrill, and others. This file provides a sane
    | default location for this type of information, allowing packages
    | to have a conventional place to find your various credentials.
    |
    */

    'mailgun' => [
        'domain' => getenv('OCTOBER_SERVICES_MAILGUN_DOMAIN') ?: '',
        'secret' => getenv('OCTOBER_SERVICES_MAILGUN_SECRET') ?: '',
    ],

    'mandrill' => [
        'secret' => getenv('OCTOBER_SERVICES_MANDRILL_SECRET') ?: '',
    ],

    'ses' => [
        'key' => getenv('OCTOBER_SERVICES_SES_KEY') ?: '',
        'secret' => getenv('OCTOBER_SERVICES_SES_SECRET') ?: '',
        'region' => getenv('OCTOBER_SERVICES_SES_REGION') ?: 'us-east-1',
    ],

    'stripe' => [
        'model'  => getenv('OCTOBER_SERVICES_STRIPE_MODEL') ?: 'User',
        'secret' => getenv('OCTOBER_SERVICES_STRIPE_SECRET') ?: '',
    ],

];

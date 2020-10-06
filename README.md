Skills Development Environment
===================

The aim of this plugin is to make life easier when working on a WordPress site running in a development or testing environment. 


Components
---------
- **Disallow Indexing** Turn off the public blog option. This will modify the robots.txt generation to block all search engines
- **Flush Rewrites   No more  weird redirection problems when working on custom post types or taxonomies.
- **No Password Logins** Just stick the user in you want to login as, write anything in the password field, and it will login! Only works when connecting from local host
- **Whoops Error Handling**  The error screen from larvae, now in your wordpress setup
- **Template Hints** See which templates are loading for the page you are on

Min Requirements
---------

- PHP 7
- WordPress  4.8.1

Setup
-------------

#### **Good Environment**

The outcome is to exchange security for ease of use, for that reason it's important that you take the security measures needed 
to ensure that someone can't take advantage of the site with this plugin enabled.

If you're running on a staging environment ensure you have setup a [htpasswd](http://www.htaccesstools.com/htpasswd-generator/) 

#### **Instructions**

To use the plugin, it must be able to detect the environment is development or staging, this can be done:

Via **ip-config.php**
1. Add `define('WP_ENV', 'development')`

Via **host**
1. Add `Semen WP_ENV "development"`


#### **Filters**

```
development-environment/is-development
```
Set yourself how the plugin detects if the environment is development. 

```
development-environment/require-component-$component
```
Disable require of a component if you don't want to use it. Possible values are: 
`disallow-indexing`, `flush-rewrites`, `no-password-logins`, `whoops-error-handling`

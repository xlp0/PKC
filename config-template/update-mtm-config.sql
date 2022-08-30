USE matomo;

update  matomo_plugin_setting
set     setting_value = '#YOUR_KCK_FQDN_DOMAIN/auth/realms/pkc-realm/protocol/openid-connect/auth'
where   plugin_name = 'LoginOIDC'
        and setting_name = 'authorizeUrl';

update  matomo_plugin_setting
set     setting_value = '#YOUR_KCK_FQDN_DOMAIN/auth/realms/pkc-realm/protocol/openid-connect/token'
where   plugin_name = 'LoginOIDC'
        and setting_name = 'tokenUrl';

update  matomo_plugin_setting
set     setting_value = '#YOUR_KCK_FQDN_DOMAIN/auth/realms/pkc-realm/protocol/openid-connect/userinfo'
where   plugin_name = 'LoginOIDC'
        and setting_name = 'userinfoUrl';

update  matomo_plugin_setting
set     setting_value = '#YOUR_KCK_FQDN_DOMAIN/auth/realms/pkc-realm/protocol/openid-connect/logout?redirect_uri=https://mtm.#YOUR_DOMAIN'
where   plugin_name = 'LoginOIDC'
        and setting_name = 'endSessionUrl';

USE gitea;

UPDATE  login_source
set     cfg = '{"Provider":"openidConnect","ClientID":"gitea-client","ClientSecret":"a82b18b0-8cdd-44be-b507-f15192202ddf","OpenIDConnectAutoDiscoveryURL":"#YOUR_KCK_FQDN_DOMAIN/auth/realms/pkc-realm/.well-known/openid-configuration","CustomURLMapping":{"AuthURL":"","TokenURL":"","ProfileURL":"","EmailURL":""},"IconURL":""}'
where   id = 1

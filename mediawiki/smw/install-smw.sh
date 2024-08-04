#!/usr/bin/env bash
if [ -f "${MW_BASE_PATH}/${MW_LOCAL_SETTINGS}" ] && [ ! -f ${MW_BASE_PATH}/${MW_COMPOSER_LOCAL} ]; then
    echo '{"require":{"mediawiki/semantic-media-wiki":"${SMW_VERSION}"}}' > ${MW_BASE_PATH}/${MW_COMPOSER_LOCAL}
    composer update --no-dev
fi
if [ -f "${MW_BASE_PATH}/${MW_LOCAL_SETTINGS}" ] && ! grep -q "SemanticMediaWiki" ${MW_BASE_PATH}/${MW_LOCAL_SETTINGS}; then
    echo "wfLoadExtension( 'SemanticMediaWiki' );" >> ${MW_BASE_PATH}/${MW_LOCAL_SETTINGS}
    echo "enableSemantics( '${SMW_WIKI_DOMAIN}' );" >> ${MW_BASE_PATH}/${MW_LOCAL_SETTINGS}
fi
/usr/local/bin/php ${MW_BASE_PATH}/maintenance/update.php

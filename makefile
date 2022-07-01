#
# Makefile
#

.PHONY: help
.DEFAULT_GOAL := help

PLUGIN_VERSION=`php -r 'echo json_decode(file_get_contents("MolliePayments/composer.json"))->version;'`

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# ------------------------------------------------------------------------------------------------------------

run: ## Starts it all
	docker-compose up -d
	open http://localhost:4000
	docker logs -f website


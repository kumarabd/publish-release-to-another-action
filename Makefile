include env.mk

test:
	GITHUB_API_URL=$(GITHUB_API_URL) INPUT_FILE=$(INPUT_FILE) GITHUB_REPOSITORY=$(GITHUB_REPOSITORY) GITHUB_TOKEN=$(GITHUB_TOKEN) TARGET=$(TARGET) ./run.sh
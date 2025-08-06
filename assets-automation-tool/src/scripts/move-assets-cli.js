const readline = require('readline');
const { FileSynchronizer } = require('./move-assets');
const FastBulkDownloader = require('./download-tool');
const { ConfigManager } = require('../utils/common');
const { logger } = require('../utils/logger');

const FULL = 'full';
const DOWNLOAD = 'download';
const COPY = 'copy';
const ALL = 'all';
const TWO_D = '2d';
const THREE_D = '3d';
const SPECIFIC = 'specific';

class AssetsAutomationCLI {
    constructor() {
        this.rl = readline.createInterface({
            input: process.stdin,
            output: process.stdout
        });
        this.configManager = ConfigManager.getInstance();
    }

    async run() {
        try {
            logger.info('🎮 Welcome to Assets Automation CLI Tool!');
            await this.configManager.loadFolderMapping();
            logger.success('✅ Configuration loaded successfully');
            await this.promptOperationType();
        } catch (error) {
            logger.error(`❌ Error: ${error.message}`);
        } finally {
            this.rl.close();
        }
    }

    async promptOperationType() {
        logger.info('\n🚀 Select operation type:');
        logger.info(`   1. ${FULL}      - Download + Copy (complete workflow)`);
        logger.info(`   2. ${DOWNLOAD}  - Download assets from Google Drive`);
        logger.info(`   3. ${COPY}  - Copy/sync downloaded assets to project`);

        const choice = await this.askSelect('Please select operation (1-3): ', ['1', '2', '3', FULL, DOWNLOAD, COPY]);
        const operationMap = {
            '1': FULL,
            '2': DOWNLOAD,
            '3': COPY,
            [FULL]: FULL,
            [DOWNLOAD]: DOWNLOAD,
            [COPY]: COPY,
        };
        const operation = operationMap[choice];
        await this.promptTargetSelection(operation);
    }

    async promptTargetSelection(operation) {
        logger.info(`\n📦 Select target for ${operation}:`);
        logger.info(`   1. ${SPECIFIC}  - Specify a particular item`);
        logger.info(`   2. ${ALL}       - Process all assets`);
        logger.info(`   3. ${TWO_D}        - Process 2D assets only`);
        logger.info(`   4. ${THREE_D}        - Process 3D assets only`);

        const choice = await this.askSelect('Please select target (1-4): ', ['1', '2', '3', '4', SPECIFIC, ALL, TWO_D, THREE_D]);

        let target = ALL;
        const targetMap = {
            '1': SPECIFIC,
            '2': ALL,
            '3': TWO_D,
            '4': THREE_D,
            [SPECIFIC]: SPECIFIC,
            [ALL]: ALL,
            [TWO_D]: TWO_D,
            [THREE_D]: THREE_D
        };

        target = targetMap[choice];

        if (target === SPECIFIC) {
            target = await this.selectSpecificItem();
        }

        await this.confirmAndExecute(operation, target);
    }

    async selectSpecificItem() {
        const config = this.configManager.folderMapping || this.configManager.loadFolderMappingSync();
        const availableItems = Object.keys(config.items);

        logger.info('\n📋 Available items:');
        availableItems.forEach((item, index) => {
            const description = config.items[item].description;
            logger.info(`   ${index + 1}. ${item} - ${description}`);
        });

        const choice = await this.askQuestion('Enter item name or number: ');
        const itemIndex = parseInt(choice.trim()) - 1;

        if (!isNaN(itemIndex) && itemIndex >= 0 && itemIndex < availableItems.length) {
            return availableItems[itemIndex];
        }

        if (availableItems.includes(choice.trim())) {
            return choice.trim();
        }

        logger.warn('❌ Invalid item, please try again');
        return await this.selectSpecificItem();
    }

    async confirmAndExecute(operation, target) {
        logger.info(`\n📋 Summary:`);
        logger.info(`   Operation: ${operation}`);
        logger.info(`   Target: ${target}`);

        const confirmed = await this.askQuestion('\nConfirm execution? (y/n): ');
        if (['y', 'yes'].includes(confirmed.toLowerCase())) {
            await this.executeOperation(operation, target);
        } else {
            logger.info('❌ Operation cancelled');
        }
    }

    async executeOperation(operation, target) {
        try {
            switch (operation) {
                case DOWNLOAD:
                    await this.executeDownload(target);
                    break;
                case COPY:
                    await this.executeCopy(target);
                    break;
                case FULL:
                    logger.info('🔄 Starting full workflow...');
                    await this.executeDownload(target);
                    logger.info('📋 Download completed, starting copy...');
                    await this.executeCopy(target);
                    logger.success('✅ Full workflow completed!');
                    break;
            }
        } catch (error) {
            logger.error(`❌ Operation failed: ${error.message}`);
        }
    }

    async executeDownload(target) {
        logger.info(`📥 Starting download for target: ${target}`);
        const downloader = new FastBulkDownloader({ detail: false });
        await downloader.initialize();

        const itemsToProcess = this.configManager.getItemsToProcess(target);
        if (itemsToProcess.length === 0) {
            logger.info('ℹ️  No items to process');
            return;
        }

        downloader.downloadStats.startTime = Date.now();

        for (const itemName of itemsToProcess) {
            try {
                await downloader.downloadItem(itemName);
            } catch (error) {
                logger.error(`❌ Download failed ${itemName}:`, error.message);
                downloader.downloadStats.failed++;
            }
        }

        downloader.showFinalStats();
    }

    async executeCopy(target) {
        logger.info(`📋 Starting copy/sync for target: ${target}`);
        const options = { type: target };
        const synchronizer = new FileSynchronizer(options);
        await synchronizer.run();
    }

    askQuestion(question) {
        return new Promise((resolve) => {
            this.rl.question(question, (answer) => {
                resolve(answer.trim());
            });
        });
    }

    async askSelect(question, validOptions) {
        const answer = await this.askQuestion(question);
        if (validOptions.includes(answer)) return answer;
        logger.warn('❌ Invalid input, please try again');
        return await this.askSelect(question, validOptions);
    }
}

async function main() {
    const cli = new AssetsAutomationCLI();
    await cli.run();
}

if (require.main === module) {
    main();
}

module.exports = AssetsAutomationCLI;

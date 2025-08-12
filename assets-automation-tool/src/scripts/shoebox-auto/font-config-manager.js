#!/usr/bin/env node

/**
 * Font Configuration Manager
 * 字體配置管理器 - 統一管理不同字體類型的配置
 */

const fs = require('fs');
const path = require('path');

class FontConfigManager {
    constructor() {
        this.basePath = path.join(__dirname, '../../../config');
        this.imageHeightsPath = path.join(this.basePath, 'image-heights.json');
        
        // 支援的字體類型配置
        this.fontTypes = {
            'font-multiplier': {
                configFile: 'font-multiplier-config.json',
                shoeboxFile: 'font-multiplier.sbx',
                imageFile: 'font-multiplier.png',
                chars: '0123456789x.,',
                message: '0123456789x.,'
            },
            'font-number': {
                configFile: 'font-number-config.json', 
                shoeboxFile: 'font-number.sbx',
                imageFile: 'font-number.png',
                chars: '0123456789,.',
                message: '0123456789,.'
            }
        };
    }

    /**
     * 取得字體高度
     */
    getFontHeight(fontType) {
        try {
            const imageHeights = JSON.parse(fs.readFileSync(this.imageHeightsPath, 'utf8'));
            const fontConfig = this.fontTypes[fontType];
            
            if (!fontConfig) {
                throw new Error(`不支援的字體類型: ${fontType}`);
            }
            
            const heightData = imageHeights.heights.find(h => h.file === fontConfig.imageFile);
            
            if (!heightData) {
                console.warn(`⚠️ 找不到 ${fontConfig.imageFile} 的高度資料，使用預設值 37`);
                return 37;
            }
            
            return heightData.height;
        } catch (error) {
            console.error('❌ 讀取圖片高度失敗:', error.message);
            return 37;
        }
    }

    /**
     * 生成字體配置
     */
    generateFontConfig(fontType) {
        const fontConfig = this.fontTypes[fontType];
        if (!fontConfig) {
            throw new Error(`不支援的字體類型: ${fontType}`);
        }

        const height = this.getFontHeight(fontType);
        
        const config = {
            "ui-position": {
                "fileFormat": {
                    "loop": { "x": 1200, "y": 200 },
                    "outer": { "x": 1200, "y": 235 },
                    "txtLineHeight": { "x": 1165, "y": 545 }
                }
            },
            [fontType]: {
                "fileFormat": {
                    "loop": "char id=@id x=@x y=@y width=@w height=@h xoffset=@sx yoffset=0 xadvance=@advanceX page=0 chnl=0 letter=\"@letter\"",
                    "loopKerning": "kerning first=@kernPairIdA  second=@kernPairIdB  amount=@kernPairAmount\\n",
                    "outer": `info face="@fileName" size=變數 bold=0 italic=0 charset="" unicode=0 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=@padding,@padding\\ncommon lineHeight=變數 base=26 scaleW=@texW scaleH=@texH pages=1 packed=0 alphaChnl=1 redChnl=0 greenChnl=0 blueChnl=0\\npage id=0 file="@fileName.png"\\nchars count=@count\\n@loop\\nkernings count=@kernPairCount\\n@kernLoop`
                },
                "fileGenerate2x": false,
                "fileName": fontConfig.imageFile.replace('.png', '.fnt'),
                "kerning": {
                    "buildPairs": false,
                    "pairs": "A' AC AG AO AQ AT AU AV AW AY BA BE BL BP BR BU BV BW BY CA CO CR DA DD DE DI DL DM DN DO DP DR DU DV DW DY EC EO FA FC FG FO F. F, GE GO GR GU HO IC IG IO JA JO KO L' LC LT LV LW LY LG LO LU M MG MO NC NG NO OA OB OD OE OF OH OI OK OL OM ON OP OR OT OU OV OW OX OY PA PE PL PO PP PU PY P. P, P; P: QU RC RG RY RT RU RV RW RY SI SM ST SU TA TC TO UA UC UG UO US VA VC VG VO VS WA WC WG WO YA YC YO YS ZO",
                    "rays": 8,
                    "value": 1
                },
                "mergeBlobSize": 2,
                "message": fontConfig.message,
                "texture": {
                    "extrudeSize": 0,
                    "maxSize": 2048,
                    "padding": 1,
                    "powerOfTwo": true
                },
                "text": {
                    "chars": fontConfig.chars,
                    "lineHeight": height,
                    "monospace": false,
                    "spaceWidth": 20,
                    "tabSizeSpaces": 8
                }
            }
        };

        return config;
    }

    /**
     * 生成 Shoebox 配置
     */
    generateShoeboxConfig(fontType) {
        const fontConfig = this.fontTypes[fontType];
        if (!fontConfig) {
            throw new Error(`不支援的字體類型: ${fontType}`);
        }

        const height = this.getFontHeight(fontType);
        const outerTemplate = `info face="@fileName" size=${height} bold=0 italic=0 charset="" unicode=0 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=@padding,@padding\\ncommon lineHeight=${height} base=26 scaleW=@texW scaleH=@texH pages=1 packed=0 alphaChnl=1 redChnl=0 greenChnl=0 blueChnl=0\\npage id=0 file="@fileName.png"\\nchars count=@count\\n@loop\\nkernings count=@kernPairCount\\n@kernLoop`;

        const shoeboxConfig = {
            "version": 3,
            "scripts": [{
                "tool": "bitmap-font",
                "data": {
                    "message": fontConfig.message,
                    "fileName": fontConfig.imageFile.replace('.png', '.fnt'),
                    "fileGenerate2x": false,
                    "text": {
                        "chars": fontConfig.chars,
                        "lineHeight": height,
                        "monospace": false,
                        "spaceWidth": 20,
                        "tabSizeSpaces": 8
                    },
                    "texture": {
                        "extrudeSize": 0,
                        "maxSize": 2048,
                        "padding": 1,
                        "powerOfTwo": true
                    },
                    "fileFormat": {
                        "loop": "char id=@id x=@x y=@y width=@w height=@h xoffset=@sx yoffset=0 xadvance=@advanceX page=0 chnl=0 letter=\"@letter\"",
                        "loopKerning": "kerning first=@kernPairIdA  second=@kernPairIdB  amount=@kernPairAmount\\n",
                        "outer": outerTemplate
                    },
                    "kerning": {
                        "buildPairs": false,
                        "pairs": "A' AC AG AO AQ AT AU AV AW AY BA BE BL BP BR BU BV BW BY CA CO CR DA DD DE DI DL DM DN DO DP DR DU DV DW DY EC EO FA FC FG FO F. F, GE GO GR GU HO IC IG IO JA JO KO L' LC LT LV LW LY LG LO LU M MG MO NC NG NO OA OB OD OE OF OH OI OK OL OM ON OP OR OT OU OV OW OX OY PA PE PL PO PP PU PY P. P, P; P: QU RC RG RY RT RU RV RW RY SI SM ST SU TA TC TO UA UC UG UO US VA VC VG VO VS WA WC WG WO YA YC YO YS ZO",
                        "rays": 8,
                        "value": 1
                    },
                    "mergeBlobSize": 2
                },
                "locked": false
            }]
        };

        return shoeboxConfig;
    }

    /**
     * 更新所有配置文件
     */
    updateConfigs(fontType) {
        try {
            const fontConfig = this.fontTypes[fontType];
            if (!fontConfig) {
                throw new Error(`不支援的字體類型: ${fontType}`);
            }

            console.log(`🔄 更新 ${fontType} 配置文件...`);

            // 生成並寫入 JSON 配置
            const jsonConfig = this.generateFontConfig(fontType);
            const jsonPath = path.join(this.basePath, fontConfig.configFile);
            fs.writeFileSync(jsonPath, JSON.stringify(jsonConfig, null, 2));
            console.log(`✅ 已更新: ${fontConfig.configFile}`);

            // 生成並寫入 Shoebox 配置
            const shoeboxConfig = this.generateShoeboxConfig(fontType);
            const shoeboxPath = path.join(this.basePath, 'shoebox-config', fontConfig.shoeboxFile);
            fs.writeFileSync(shoeboxPath, JSON.stringify(shoeboxConfig));
            console.log(`✅ 已更新: ${fontConfig.shoeboxFile}`);

            const height = this.getFontHeight(fontType);
            console.log(`📏 字體高度: ${height}px`);

        } catch (error) {
            console.error('❌ 更新配置失敗:', error.message);
            process.exit(1);
        }
    }

    /**
     * 顯示幫助資訊
     */
    showHelp() {
        console.log('Font Configuration Manager');
        console.log('===========================');
        console.log('');
        console.log('使用方法: node font-config-manager.js [command] [font-type]');
        console.log('');
        console.log('Commands:');
        console.log('  update    - 更新配置文件');
        console.log('  height    - 顯示字體高度');
        console.log('  list      - 列出支援的字體類型');
        console.log('');
        console.log('Font Types:');
        Object.keys(this.fontTypes).forEach(type => {
            console.log(`  ${type.padEnd(15)} - ${this.fontTypes[type].imageFile}`);
        });
        console.log('');
        console.log('範例:');
        console.log('  node font-config-manager.js update font-multiplier');
        console.log('  node font-config-manager.js height font-number');
        console.log('  node font-config-manager.js list');
    }
}

// 主程式
function main() {
    const manager = new FontConfigManager();
    const args = process.argv.slice(2);

    if (args.length === 0 || args[0] === '--help' || args[0] === '-h') {
        manager.showHelp();
        return;
    }

    const command = args[0];
    const fontType = args[1];

    switch (command) {
        case 'update':
            if (!fontType) {
                console.error('❌ 請指定字體類型');
                manager.showHelp();
                process.exit(1);
            }
            manager.updateConfigs(fontType);
            break;

        case 'height':
            if (!fontType) {
                console.error('❌ 請指定字體類型');
                process.exit(1);
            }
            const height = manager.getFontHeight(fontType);
            console.log(`📏 ${fontType} 字體高度: ${height}px`);
            break;

        case 'list':
            console.log('支援的字體類型:');
            Object.keys(manager.fontTypes).forEach(type => {
                const config = manager.fontTypes[type];
                const height = manager.getFontHeight(type);
                console.log(`  ${type.padEnd(15)} - ${config.imageFile.padEnd(25)} (${height}px)`);
            });
            break;

        default:
            console.error(`❌ 未知命令: ${command}`);
            manager.showHelp();
            process.exit(1);
    }
}

if (require.main === module) {
    main();
}

module.exports = FontConfigManager;

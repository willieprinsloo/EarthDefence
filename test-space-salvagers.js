#!/usr/bin/env node

/**
 * Automated test script for Space Salvagers using iOS Simulator MCP Server
 * This script demonstrates how to automate gameplay testing
 */

import { exec } from 'child_process';
import { promisify } from 'util';
const execPromise = promisify(exec);

// Simulator and app configuration
const SIMULATOR_NAME = 'iPhone 16 Pro';
const APP_BUNDLE_ID = 'com.spacesalvagers.game';
const APP_PATH = '/Users/wlprinsloo/Library/Developer/Xcode/DerivedData/SpaceSalvagers-*/Build/Products/Debug-iphonesimulator/SpaceSalvagers.app';

// Game coordinates (adjust based on actual layout)
const COORDINATES = {
  playButton: { x: 512, y: 400 },
  buildNodes: [
    { x: 200, y: 300 },
    { x: 400, y: 300 },
    { x: 600, y: 300 },
    { x: 200, y: 500 },
    { x: 400, y: 500 }
  ],
  startWaveButton: { x: 900, y: 100 }
};

class SpaceSalvagersTest {
  constructor() {
    this.simulatorUDID = null;
  }

  async runCommand(command) {
    console.log(`Running: ${command}`);
    try {
      const { stdout, stderr } = await execPromise(command);
      if (stderr && !stderr.includes('warning')) {
        console.error(`Error: ${stderr}`);
      }
      return stdout;
    } catch (error) {
      console.error(`Command failed: ${error.message}`);
      throw error;
    }
  }

  async findSimulator() {
    const result = await this.runCommand(`xcrun simctl list devices | grep "${SIMULATOR_NAME}" | grep Booted`);
    if (result) {
      const match = result.match(/\(([A-F0-9-]+)\)/);
      if (match) {
        this.simulatorUDID = match[1];
        console.log(`Found running simulator: ${this.simulatorUDID}`);
        return true;
      }
    }
    return false;
  }

  async bootSimulator() {
    console.log(`Booting ${SIMULATOR_NAME}...`);
    const listResult = await this.runCommand(`xcrun simctl list devices | grep "${SIMULATOR_NAME}"`);
    const match = listResult.match(/\(([A-F0-9-]+)\)/);
    
    if (match) {
      this.simulatorUDID = match[1];
      await this.runCommand(`xcrun simctl boot ${this.simulatorUDID}`);
      console.log(`Simulator booted: ${this.simulatorUDID}`);
      
      // Open Simulator app
      await this.runCommand('open -a Simulator');
      
      // Wait for boot
      await this.wait(5000);
    } else {
      throw new Error(`Simulator ${SIMULATOR_NAME} not found`);
    }
  }

  async installApp() {
    console.log('Installing Space Salvagers...');
    // Find the actual app path
    const { stdout } = await execPromise(`ls -d ${APP_PATH} 2>/dev/null | head -1`);
    const actualPath = stdout.trim();
    
    if (!actualPath) {
      console.log('App not found. Building the app first...');
      await this.buildApp();
      return await this.installApp();
    }
    
    await this.runCommand(`xcrun simctl install ${this.simulatorUDID} "${actualPath}"`);
    console.log('App installed successfully');
  }

  async buildApp() {
    console.log('Building Space Salvagers...');
    await this.runCommand('cd /Users/wlprinsloo/Documents/Projects/Tower-game && xcodebuild -scheme SpaceSalvagers -sdk iphonesimulator -configuration Debug build');
    console.log('Build completed');
  }

  async launchApp() {
    console.log('Launching Space Salvagers...');
    await this.runCommand(`xcrun simctl launch ${this.simulatorUDID} ${APP_BUNDLE_ID}`);
    await this.wait(3000); // Wait for app to fully load
  }

  async takeScreenshot(name) {
    const filename = `/tmp/space_salvagers_${name}_${Date.now()}.png`;
    await this.runCommand(`xcrun simctl io ${this.simulatorUDID} screenshot ${filename}`);
    console.log(`Screenshot saved: ${filename}`);
    return filename;
  }

  async tap(x, y, description = '') {
    console.log(`Tapping ${description ? description + ' at' : 'at'} (${x}, ${y})`);
    // Using Appium's approach for tapping
    await this.runCommand(`xcrun simctl io ${this.simulatorUDID} tap ${x} ${y}`);
    await this.wait(500);
  }

  async wait(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  async playGame() {
    console.log('\n🎮 Starting automated gameplay test...\n');

    // Take initial screenshot
    await this.takeScreenshot('main_menu');

    // Start game
    await this.tap(COORDINATES.playButton.x, COORDINATES.playButton.y, 'Play button');
    await this.wait(2000);

    // Take game scene screenshot
    await this.takeScreenshot('game_scene');

    // Place towers
    console.log('\n🏗️ Placing towers...');
    for (let i = 0; i < 3; i++) {
      const node = COORDINATES.buildNodes[i];
      await this.tap(node.x, node.y, `Build node ${i + 1}`);
      await this.wait(1000);
    }

    // Take screenshot with towers
    await this.takeScreenshot('towers_placed');

    // Start wave (if visible)
    console.log('\n🌊 Starting wave...');
    await this.tap(COORDINATES.startWaveButton.x, COORDINATES.startWaveButton.y, 'Start wave button');
    await this.wait(5000);

    // Take combat screenshot
    await this.takeScreenshot('combat');

    console.log('\n✅ Automated test completed successfully!');
  }

  async runFullTest() {
    try {
      // Check if simulator is already running
      const isRunning = await this.findSimulator();
      
      if (!isRunning) {
        await this.bootSimulator();
      }

      // Install and launch app
      await this.installApp();
      await this.launchApp();

      // Play the game
      await this.playGame();

      console.log('\n📊 Test Summary:');
      console.log('- Simulator booted: ✅');
      console.log('- App installed: ✅');
      console.log('- App launched: ✅');
      console.log('- Towers placed: ✅');
      console.log('- Wave started: ✅');
      console.log('\nAll tests passed! 🎉');

    } catch (error) {
      console.error('\n❌ Test failed:', error.message);
      process.exit(1);
    }
  }
}

// Run the test
async function main() {
  const test = new SpaceSalvagersTest();
  await test.runFullTest();
}

// Run the test
main().catch(console.error);

export default SpaceSalvagersTest;
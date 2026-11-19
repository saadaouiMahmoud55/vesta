const { getDefaultConfig } = require('expo/metro-config');

/** Configuration Metro d'Expo (gère polices/images et le runtime Expo Go). */
const config = getDefaultConfig(__dirname);

module.exports = config;

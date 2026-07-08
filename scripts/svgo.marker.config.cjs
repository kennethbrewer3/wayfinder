/** Aggressive SVGO preset for marker icons displayed at small map sizes. */
module.exports = {
  multipass: true,
  plugins: [
    {
      name: 'preset-default',
      params: {
        overrides: {
          cleanupIds: false,
        },
      },
    },
    {
      name: 'convertPathData',
      params: { floatPrecision: 1 },
    },
    {
      name: 'cleanupNumericValues',
      params: { floatPrecision: 1 },
    },
  ],
};

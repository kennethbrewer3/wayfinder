/** Gentle SVGO preset for marker_pin.svg (layout ids must be preserved). */
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
  ],
};

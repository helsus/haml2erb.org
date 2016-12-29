const webpack = require('webpack');
const ExtractTextPlugin = require('extract-text-webpack-plugin');


const IS_PRODUCTION = process.env.NODE_ENV === 'production';

let plugins = [
  new ExtractTextPlugin('styles/styles.css'),
  new webpack.DefinePlugin({
    'process.env.NODE_ENV': `"${process.env.NODE_ENV}"`,
  }),
];

if (IS_PRODUCTION) {
  plugins = [...plugins,
    new webpack.optimize.UglifyJsPlugin(),
    new webpack.optimize.OccurenceOrderPlugin(),
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.AggressiveMergingPlugin(),
  ];
}

module.exports = {
  resolve: {
    extensions: ['', '.js', 'json', '.scss', '.css'],
  },
  devtool: IS_PRODUCTION ? '' : 'source-map',
  stats: {
    colors: true,
    reasons: true,
  },
  entry: ['whatwg-fetch', './web/assets/entry.js'],
  output: {
    path: './web/public',
    filename: 'scripts/main.js',
  },
  module: {
    preLoaders: [
      { test: /\.js$/, loader: 'eslint', exclude: /node_modules/ },
    ],
    loaders: [
      {
        test: /\.js$/,
        loader: 'babel',
        exclude: /node_modules/,
      },
      {
        test: /\.s?css$/,
        loader: ExtractTextPlugin.extract('style', 'css?sourceMap!sass?sourceMap'),
      },
    ],
  },
  plugins,
};

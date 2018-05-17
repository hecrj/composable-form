const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
  entry: {
    app: [
      './index.js'
    ]
  },

  output: {
    path: path.resolve(__dirname, '../docs'),
    publicPath: '/elm-wip-form/',
    filename: '[name].[hash].js'
  },

  resolve: {
    modules: [
      "node_modules",
      path.resolve(__dirname, 'src')
    ]
  },

  plugins: [
    new MiniCssExtractPlugin({
      filename: "[name].[hash].css",
      chunkFilename: "[id].css"
    }),
    new HtmlWebpackPlugin({
      template: './index.html'
    })
  ],

  module: {
    rules: [
      {
        test:    /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [
          {
            loader: 'elm-webpack-loader',
            options: {
              warn: true
            }
          }
        ]
      },
      {
        test: /\.css$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader'
        ]
      },
      {
        test: /\.scss$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          'sass-loader'
        ]
      },
    ]
  },

  devServer: {
    inline: true,
    stats: { colors: true },
    historyApiFallback: false,
    host: '0.0.0.0',
    disableHostCheck: true,
    stats: {
      hash: false,
      version: false,
      timings: false,
      assets: false,
      chunks: false,
      modules: false,
      reasons: false,
      children: false,
      source: false,
      errors: true,
      errorDetails: true,
      warnings: true,
      publicPath: false
    }
  },

};

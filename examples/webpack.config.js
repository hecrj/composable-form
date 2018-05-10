const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const ExtractTextPlugin = require('extract-text-webpack-plugin');

module.exports = {
  entry: {
    app: [
      './index.js'
    ]
  },

  output: {
    path: path.resolve(__dirname, '../docs'),
    publicPath: '/',
    filename: '[name].[hash].js'
  },

  resolve: {
    modules: [
      "node_modules",
      path.resolve(__dirname, 'src')
    ]
  },

  plugins: [
    new ExtractTextPlugin('styles.[hash].css'),
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
              pathToMake: './elm-make',
              yes: false
            }
          }
        ]
      },
      {
        test: /\.css$/,
        use: ExtractTextPlugin.extract({
          use: ['css-loader']
        })
      },
      {
        test: /\.scss$/,
        use: ExtractTextPlugin.extract({
          use: [
          'css-loader',
          'sass-loader'
        ]})
      },
    ]
  },

  devServer: {
    inline: true,
    stats: { colors: true },
    historyApiFallback: true,
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

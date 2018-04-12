'use strict';

import 'normalize.css'
import './styles.scss'

// Elm
var Elm = require('Main.elm');
var node = document.getElementById('elm-app');
var app = Elm.Main.embed(node);


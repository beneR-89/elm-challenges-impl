'use strict';

require('bootstrap/dist/css/bootstrap.min.css');
require('font-awesome/css/font-awesome.css');
require('./style/custom.scss');

require('./index.html');

var Highscore = require('./Challenges/Common/Highscore/Highscore.js');

var Elm = require('./Main.elm');
var mountNode = document.getElementById('main');

var app = Elm.Main.embed(mountNode);

var appName = 'elm-snake-challenge';
Highscore.restoreHighscore(app, appName);
Highscore.subscribeHighscore(app, appName);

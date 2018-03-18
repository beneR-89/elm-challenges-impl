export function subscribeHighscore(app, appName) {
  app.ports.saveHighscore.subscribe(function(highscore) {
    localStorage.setItem(appName, highscore);
  });
};

export function restoreHighscore(app, appName) {
  var highscore = localStorage.getItem(appName);
  if (highscore != null) {
    app.ports.initialHighscore.send(highscore.toString());
  }
};

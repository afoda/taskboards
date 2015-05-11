Package.describe({
  name: 'sweep',
  version: '0.1.0',
  summary: 'sweep.js packaged for Meteor',
  documentation: null
});

Package.onUse(function(api) {
  api.versionsFrom('1.1');
  api.addFiles('sweep.min.js');
});

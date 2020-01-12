var dbPass = "Passw0rd"
var clusterName = "testCluster"

try {
  print('Setting up InnoDB cluster...\n');
  shell.connect('icadmin@sqlnode1:3306', dbPass)
  var cluster = dba.createCluster(clusterName);
  print('Adding instances to the cluster.');
  cluster.addInstance({user: "icadmin", host: "sqlnode2", port: "3306", password: dbPass}, {recoveryMethod: "clone"})
  print('.');
  cluster.addInstance({user: "icadmin", host: "sqlnode3", port: "3306", password: dbPass}, {recoveryMethod: "clone"})
  print('.\nInstances successfully added to the cluster.');
  print('\nInnoDB cluster deployed successfully.\n');
} catch(e) {
  print('\nThe InnoDB cluster could not be created.\n\nError: ' + e.message + '\n');
}

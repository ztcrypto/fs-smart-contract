module.exports = {
    networks: {
    development: {
    host: "localhost",
    port: 8545,
    network_id: "*" // Match any network id
   }
  },
  compilers: {
    solc: {
      version: "0.5.10",  
      docker: false,
      settings: {
        optimizer: {
          enabled: true, 
          runs: 200    
        }
      }
    }
  }
 };
 

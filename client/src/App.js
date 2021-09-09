import React, { Component } from "react";
import axios from 'axios';
import MetaturfAPIConsumerContract from "./contracts/MetaturfAPIConsumer.json";
import getWeb3 from "./getWeb3";

import "./App.css";

class App extends Component {
  state = { storageValue: 0, web3: null, accounts: null, contract: null, daysofraces: [], races: [] };

  componentDidMount = async () => {
  
    /*
    try {
      axios.get(`https://jsonplaceholder.typicode.com/users`, { mode: 'cors' })
      .then(res => {
        const races = res.data;
        this.setState({ races });
      })
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load races.`,
      );
      console.error(error);
    }
    */

    /*
    {"code":1,
     "status":200,
     "data":
      {"rows":[
        {"racesdate":"20210905","racecourseid":"3","racecourse":"Lasarte","racesdate_verbose":"05 Septiembre"},
        {"racesdate":"20210829","racecourseid":"3","racecourse":"Lasarte","racesdate_verbose":"29 Agosto"},
        {"racesdate":"20210828","racecourseid":"15","racecourse":"La S\u00e9nia","racesdate_verbose":"28 Agosto"},
        {"racesdate":"20210826","racecourseid":"1","racecourse":"La Zarzuela","racesdate_verbose":"26 Agosto"}]}}
    */
    try {
      axios.get(`https://ghdbadmin.metaturf.com/rest/rest_web3.php?resource=lastresults&id=14&format=json`)
      .then(res => {
        const daysofraces = res.data.data.rows;
        this.setState({ daysofraces });
  
        console.log(JSON.stringify({ daysofraces}, null, 2));

        console.log(res.data.data.rows.length);

        let i=0, race_request, racesdate, racecourseid;

          for (i = 0; i < res.data.data.rows.length; i++) {
            try {
            console.log(res.data.data.rows[i]["racecourse"] + "-" + res.data.data.rows[i]["racecourseid"] + 
                                              "-" + res.data.data.rows[i]["racesdate"]);
            
            racesdate = res.data.data.rows[i]["racesdate"];
            racecourseid = res.data.data.rows[i]["racecourseid"];

            race_request = "https://ghdbadmin.metaturf.com/rest/rest_web3.php?resource=listraces&id=" +
                            racecourseid + "&date=" + racesdate + "&format=json";

            /* {"code":1,"status":200,"data":"7178,7182,7179,7183,7184,7180,7181"} */
            console.log(race_request);

            axios.get(race_request)
            .then(res_race => {
            const races = res_race.data.data;
            //this.setState({ races });
            console.log(JSON.stringify({ races }, null, 2));
          })
        } catch (error) {
          // Catch any errors for any of the above operations.
          alert(
            `Failed to load races.`,
          );
          console.error(error);
        }
          }
          
          /* {"code":1,"status":200,"data":{"horseinfo":"13882,GALILODGE (FR),1"}} */
      })
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load days of races.`,
      );
      console.error(error);
    }

    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = MetaturfAPIConsumerContract.networks[networkId];
      const instance = new web3.eth.Contract(
        MetaturfAPIConsumerContract.abi,
        deployedNetwork && deployedNetwork.address,
      );

      const data = await instance.methods.winnerRawText().call();
      this.setState({ storageValue: data });

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ web3, accounts, contract: instance }, this.runExample);
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  //getData = async () => {

  //  }


  runExample = async () => {
    const { accounts, contract } = this.state;

    // Stores a given value, 5 by default.
    //await contract.methods.set(42).send({ from: accounts[0] });

    // Get the value from the contract to prove it worked.
    //const response = await contract.methods.requestRaceWinner("7122").call();
    //const response = await contract.methods.requestRaceWinner(7122).call();
    
    // Update state with the result.
    //this.setState({ storageValue: data });
  };

  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h1>Metaturf</h1>
        <p>Informaci&oacute;n de carreras</p>
        <h2>Smart Contract de ejemplo</h2>
        <div>The stored value is: {this.state.storageValue}</div><br></br>
        <div>Your account is: {this.state.accounts[0]}</div>
        <div>Datos: {/*this.state.moredata*/}</div>
        <ul>
          {/*this.state.races.map(user => <li>{user.phone}</li>)*/}
          {this.state.daysofraces.length}
          {this.state.daysofraces.map(date => <li>Jornada de carreras: {date.racesdate}</li>)}
          {/*this.state.races.map(user => <li>{racesdate}</li>)*/}
        </ul>
      </div>
      

    );
  }
}

export default App;

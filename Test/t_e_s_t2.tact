    import "@stdlib/deploy";
    struct GameList {
        adresses: map<Int as uint16, Address>;
        count : Int as uint16;
        value : Int;
        lottery : Int;
    }

    // Extension mutation function for adding new entries to the end of the GameList
    extends mutates fun add(self: GameList, addr: Address,MaxGameListSize : Int,val: Int) : Bool {
        if(self.count + 1 > MaxGameListSize) {
            return false;
        }
        // require(self.count + 1 <= MaxGameListSize, "No space in the GameList left for new addresses!");

        self.adresses.set(self.count + 1, addr); // Set the entry (key-value pair)
        self.count += 1;                     // Increment the count field
        self.value += val;
        return true;
    }

    fun emptyGameList(time : Int): GameList {
        return GameList{
        adresses: emptyMap(), count: 0,value : 0, lottery : now()+time}; // length defaults to 0
    }

contract TEST2 with Deployable {
    //     Empty init() function is present by default in all Tact contracts
        //     since v1.3.0, so the following may be omitted:
        maxPlan4Participant: Int as uint16;
        gameListPlan4 : GameList; //every day
        lastWinnerPlan4 : Address;
        owner : Address; //setting the first address for main

        init() {
            self.maxPlan4Participant = 30000;
            self.gameListPlan4 = emptyGameList(24*60*60);
            self.owner = sender();
            self.lastWinnerPlan4 = sender();
        }


        receive() {
            if(context().value < ton("0.49")) {
                //if(self.gameListPlan4.lottery >= now() && self.gameListPlan4.count > 0) {
                let r1 = random(1,self.gameListPlan4.count+1);
                let r2 = random(1,self.gameListPlan4.count+1);
                let r3 = random(1,self.gameListPlan4.count+1);
                let winner = random(1,4);
                if(winner == 1){
                    winner = r1;
                } else if (winner == 2) {
                    winner = r2;
                } else {
                    winner = r3;
                }
                let winnerAddress = self.gameListPlan4.adresses.get(winner);
                send(SendParameters{
                to: winnerAddress!!,
                bounce: true,
                value: self.gameListPlan4.value - 100000000,
                mode: SendIgnoreErrors
                });
                self.lastWinnerPlan4 = winnerAddress!!;
                emptyGameList(24*60*60);
            //}
            }
            else {
            require(context().value >= ton("0.49"),"Not valid value of ton");
            let commission : Int = context().value / 5;  // 20% commission
            require(self.gameListPlan4.add(sender(),self.maxPlan4Participant,context().value-commission-10000000),"No space in the GameList left for new addresses!"); // should test for cash back if people are max
            send(SendParameters{
            to: self.owner,
            bounce: true,
            value: commission-10000000,
            mode: SendIgnoreErrors
            });
            }
        }
        
    }
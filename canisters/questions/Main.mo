import Map "mo:base/HashMap";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Types "./Types";
import List "mo:base/List";
import Buffer "mo:base/Buffer";
import Trie "mo:base/Trie";
import Time "mo:base/Time";
import Principal "mo:base/Principal";

// Define the actor
actor Quiz {

  type Key = Nat;

  type Question = Types.Question;
  type Answer = Types.Answer;
  
  func natHash(n : Nat) : Hash.Hash { 
    Text.hash(Nat.toText(n))
  };

  func textHash(t : Text) : Hash.Hash { 
    Text.hash(t)
  };

  stable var accounts = Types.accounts_fromArray([]);
  stable var account_names = Types.account_names_fromArray([]);
  // stable var questions = Types.questions_fromArray([]);

  var questions = Map.HashMap<Nat, Question>(0, Nat.equal, natHash);
  // var answers = Map.HashMap<Nat, Answer>(0, Nat.equal, natHash);
  var system_params : Types.SystemParams = {
    player_size = 7;
  };
  var nextId : Nat = 0;
  var nextAnswerId: Nat = 0;

  func account_get(id : Principal) : ?Types.Player = Trie.get(accounts, Types.account_key(id), Principal.equal);
  func account_put(id : Principal, player : Types.Player) {
      accounts := Trie.put(accounts, Types.account_key(id), Principal.equal, player).0;
  };

  func account_name_get(id : Text) : ?Types.Player = Trie.get(account_names, Types.account_name_key(id), Text.equal);
  func account_name_put(id : Text, player : Types.Player) {
      account_names := Trie.put(account_names, Types.account_name_key(id), Text.equal, player).0;
  };

  // func question_get(id : Text) : ?Types.Question = Trie.get(questions, Types.question_key(id), Text.equal);
  // func question_put(id : Text, question : Types.Question) {
  //     questions := Trie.put(questions, Types.question_key(id), Text.equal, question).0;
  // };


  public func createAccountName(name: Text) : async Text {
    account_name_put(name, {name = name; score = 0});
    name
  };

  // public func createQuestion(name : Text, description : Text) : async Text {
  //   question_put(name, { 
  //                       name = name; 
  //                       description = description; 
  //                       state = #closed;
  //                       voters = List.nil<Principal>();
  //                       correctAnswer = 0;
  //                       points = 0;
  //                       timestamp = Time.now();
  //                       answers = Map.HashMap<Nat, Answer>(0, Nat.equal, natHash);
  //                     }
  //                 );
  //   name
  // };


  /// Lists all account names
  public query func list_open_questions() : async [Nat] {
    let buff = Buffer.Buffer<Nat>(8);
    for ( (k,v) in questions.entries()) {
      if (v.state == #open) {
        buff.add(k);
      }
    };
    return buff.toArray();
  };

  public query func list_closed_questions() : async [Nat] {
    let buff = Buffer.Buffer<Nat>(50);
    for ( (k,v) in questions.entries()) {
      if (v.state == #closed) {
        buff.add(k);
      }
    };
    return buff.toArray();
  };

  /// Lists all account names
  public query func list_accountNames() : async [Types.AccountName] {
      Iter.toArray(
        Iter.map(Trie.iter(account_names),
                  func ((name : Text, player : Types.Player)) : Types.AccountName = { name; player }))
  };

  /// Lists all accounts
  public query func list_accounts() : async [Types.Account] {
      Iter.toArray(
        Iter.map(Trie.iter(accounts),
                  func ((owner : Principal, player : Types.Player)) : Types.Account = { owner; player }))
  };

  // Returns the ID that was given to the question item
  public func addQuestion(name : Text, description : Text) : async Nat {
    let id = nextId;
    questions.put(id, { 
                        name = name; 
                        description = description; 
                        state = #closed;
                        voters = List.nil<Principal>();
                        points = 0;
                        timestamp = Time.now();
                        answers = List.nil<Answer>();
                      }
                  );
    nextId += 1;
    id
  };

  // Returns the ID that was given to the question item
  public func updateQuestion(id: Nat, name : Text, description : Text, open_state: Bool) : async Nat {
    switch(questions.get(id)) {
      case (null) { id };
      case (?question) {
        var updated_state : Types.QuestionState = #closed;
        if (open_state) {
          updated_state := #open;
        };
        let updated_question = {
          name = name;
          description = description;
          state = updated_state;
          voters = question.voters;
          points = question.points;
          timestamp = Time.now();
          answers = List.nil<Answer>();
        };
        questions.put(id, updated_question);
        id
      }
    }   
  };


  // Returns the ID that was given to the Answer item
  public func addAnswer(description : Text, score : Nat, correct: Bool, question_id: Nat) : async Nat {
    let id = nextAnswerId;
    nextAnswerId += 1;
    switch(questions.get(question_id)) {
      case (null) { id };
      case (?question) {
        let answers = List.push({id = id; description = description; score = score; correct = correct }, question.answers);
        let updated_question = {
          name = question.name;
          description = question.description;
          state = question.state;
          voters = question.voters;
          points = question.points;
          timestamp = Time.now();
          answers = answers;
        };
        questions.put(question_id, updated_question);
        id
      }
    }    
  };


  public func getQuestion(question_id: Nat) : async Types.Result<Types.MiniQuestion, Text> {
    switch(questions.get(question_id)) {
      case null { #err("No question with ID " # debug_show(question_id) # " exists") };
      case (?question) {
        let answers = List.toArray(question.answers);
        #ok({ name = question.name; description = question.description; answers = answers })
      };
    };
  };

  public func setOpen(question_id: Nat) : async () {
    switch(questions.get(question_id)) {
      case (null) { };
      case (?question) {
        let updated_question = {
          name = question.name;
          description = question.description;
          state = #open;
          voters = question.voters;
          points = question.points;
          timestamp = Time.now();
          answers = question.answers;
        };
        questions.put(question_id, updated_question);
      };
    };
  };

  public func setClosed(question_id: Nat) : async () {
    switch(questions.get(question_id)) {
      case (null) { };
      case (?question) {
        let updated_question = {
          name = question.name;
          description = question.description;
          state = #closed;
          voters = question.voters;
          points = question.points;
          timestamp = Time.now();
          answers = question.answers;
        };
        questions.put(question_id, updated_question);
      };
    };
  };

  public query func showQuestion(question_id : Nat) : async Text {
    let question = questions.get(question_id);
    switch(question) {
      case (null) { "No question"};
      case (?question) {
        var output : Text = "\n___Question___";
        output #= "\n" # question.name;
        output #= "\n" # question.description;
        List.iterate<Answer>(question.answers, func (answer : Answer) {
          output #= "\n" # answer.description;
          output #= "\n" # Nat.toText(answer.score);
        });
        output # "\n"
      }
    }
  };

  // Vote on an open question
  public shared({caller}) func vote(args: Types.Vote) : async Types.Result<Types.QuestionState, Text> {
      switch (questions.get(args.question_id)) {
        case null { #err("No question with ID " # debug_show(args.question_id) # " exists") };
        case (?question) {
          var state = question.state;
          if (state != #open) {
              return #err("Question " # debug_show(args.question_id) # " is not open for answering");
          };
          switch (account_get(caller)) {
            case null { return #err("Caller cannot play") };
            case (?player) {
              if (List.some(question.voters, func (e : Principal) : Bool = e == caller)) {
                return #err("Already voted");
              };        
              let pnts = question.points;
              let answer_id = args.answer_id;
              let ans = List.find(question.answers, func (a : Answer) : Bool = a.id == answer_id);
              switch (ans) {
                case null { return #err("Answer id does not exist") };
                case (?answer) {
                  if (answer.correct) {
                    account_put(caller, {name = player.name; score = player.score + pnts});
                  } else {
                    account_put(caller, {name = player.name; score = player.score + answer.score});
                  };
                };
              };
              let voters = List.push(caller, question.voters);
              let size = List.size<Principal>(voters);
              if (size >= system_params.player_size) {
                state := #answered;
              };

              let updated_question = {
                  name = question.name;
                  description = question.description;
                  state;
                  voters;
                  points = question.points;
                  timestamp = question.timestamp;
                  answers = question.answers;
              };
              questions.put(args.question_id, updated_question);
            };  
        };
        #ok(state)
      };
    };
  };
};
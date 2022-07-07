import Nat "mo:base/Nat";
import Text "mo:base/Text";
import List "mo:base/List";
import Hash "mo:base/Hash";
import Map "mo:base/HashMap";
import Trie "mo:base/Trie";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";

module {
  
  public type Answer = {
    id: Nat;
    description: Text;
    score: Nat;
    correct: Bool;
  };

  public type Question = {
    name: Text;
    description: Text;
    state: QuestionState;
    voters : List.List<Principal>;
    points: Nat;
    timestamp: Int;
    answers: List.List<Answer>;
  };


  public type QuestionState = {
      // A failure occurred while executing the Question
      #failed : Text;
      // The Question is open for answering
      #open;
      // The Question is currently being answered
      #answered;
      // The Question is still closed
      #closed;
      // The Question has been successfully executed
      #succeeded;
  };

  // public type MiniQuestion = {
  //   name: Text;
  //   description: Text;
  //   answer_ids: [Nat];
  // };

  public type MiniQuestion = {
    name: Text;
    description: Text;
    answers: [Answer];
  };

  public type Result<T, E> = Result.Result<T, E>;

  public type ApiError = {
    #Unauthorized;
    #InvalidParticipant;
    #ZeroAddress;
    #Other;
  };

  public type LeaderBoard = {
    leader: Account;
    history: Map.HashMap<Nat, Account>;
  };

  public type Player = {
    name: Text;
    score: Nat;
  };
  public type Account = { owner : Principal; player : Player; };
  public type AccountName = { name : Text; player : Player; };
  public type QuestionName = { name : Text; question : Question; };
  

  public type PlayerSize = Nat;
  public type Vote = { answer_id: Nat; question_id : Nat};

  public type SystemParams = {
    player_size: PlayerSize;
  };

  public type DaoStableStorage = {
    accounts: [Account];
    questions: [Question];
    system_params: SystemParams;
  };

  public func account_key(t: Principal) : Trie.Key<Principal> = { key = t; hash = Principal.hash t };

  public func accounts_fromArray(arr: [Account]) : Trie.Trie<Principal, Player> {
      var s = Trie.empty<Principal, Player>();
      for (account in arr.vals()) {
          s := Trie.put(s, account_key(account.owner), Principal.equal, account.player).0;
      };
      s
  };

  public func account_name_key(t: Text) : Trie.Key<Text> = { key = t; hash = Text.hash t };

  public func account_names_fromArray(arr: [AccountName]) : Trie.Trie<Text, Player> {
      var s = Trie.empty<Text, Player>();
      for (account_name in arr.vals()) {
          s := Trie.put(s, account_name_key(account_name.name), Text.equal, account_name.player).0;
      };
      s
  };

  public func question_key(t: Text) : Trie.Key<Text> = { key = t; hash = Text.hash t };

  // public func questions_fromArray(arr: [QuestionName]) : Trie.Trie<Text, Question> {
  //     var s = Trie.empty<Text, Question>();
  //     for (question_name in arr.vals()) {
  //         s := Trie.put(s, question_key(question_name.name), Text.equal, question_name.question).0;
  //     };
  //     s
  // };

  func natHash(n : Nat) : Hash.Hash { 
    Text.hash(Nat.toText(n))
  };

  public func questions_fromArray(arr: [Question]) : Map.HashMap<Nat, Question> {
      var s = Map.HashMap<Nat, Question>(0, Nat.equal, natHash);
      var question_id = 0;
      for (question in arr.vals()) {
          s.put(question_id, question);
          question_id += 1;
      };
      s
  };


}
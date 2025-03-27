class Profile {
  String login;
  String password;
  String level;
  String store;
  String department;
  String fullName;
  String gender;
  int age;
  String address;
  int workExperience;
  String qualification;

  Profile({
    required this.login,
    required this.password,
    required this.level,
    required this.store,
    required this.department,
    required this.fullName,
    required this.gender,
    required this.age,
    required this.address,
    required this.workExperience,
    required this.qualification,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      login: json['login'],
      password: json['password'],
      level: json['level'],
      store: json['store'],
      department: json['department'],
      fullName: json['fullName'],
      gender: json['gender'],
      age: json['age'],
      address: json['address'],
      workExperience: json['workExperience'],
      qualification: json['qualification'],
    );
  }

  Map<String, dynamic> toJson() { 
    return {
      'login': login,
      'password': password,
      'level': level,
      'store': store,
      'department': department,
      'fullName': fullName,
      'gender': gender,
      'age': age,
      'address': address,
      'workExperience': workExperience,
      'qualification': qualification,
    };
  }
  get storeName => null;

  factory Profile.empty() => Profile(
    login: '',
    password: '',
    level: '',
    store: '',
    department: '',
    fullName: '',
    gender: '',
    age: 0,
    address: '',
    workExperience: 0,
    qualification: '',
  );
}
  
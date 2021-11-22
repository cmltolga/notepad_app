class Notlar {
  int notID;
  int kategoriID;
  String notBaslik;
  String notIcerik;
  String notTarih;
  int notOncelik;
  String kategoriBaslik;

  Notlar(this.kategoriID, this.notBaslik, this.notIcerik,this.notTarih,
      this.notOncelik); // verileri yazarken

  Notlar.withID(this.notID, this.kategoriID, this.notBaslik, this.notIcerik,
      this.notTarih, this.notOncelik); // verileri okurken

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['notID'] = notID;
    map['kategoriID'] = kategoriID;
    map['notBaslik'] = notBaslik;
    map['notIcerik'] = notIcerik;
    map['notTarih'] = notTarih;
    map['notOncelik'] = notOncelik;
    return map;
  }

  Notlar.fromMap(Map<String, dynamic> map) {
    this.notID = map['notID'];
    this.kategoriID = map['kategoriID'];
    this.kategoriBaslik = map['kategoriBaslik'];
    this.notBaslik = map['notBaslik'];
    this.notIcerik = map['notIcerik'];
    this.notTarih = map['notTarih'];
    this.notOncelik = map['notOncelik'];
  }

  @override
  String toString() {
    return 'Notlar{notID: $notID, kategoriID: $kategoriID, notBaslik: $notBaslik, notIcerik: $notIcerik, notTarih: $notTarih, notOncelik: $notOncelik}';
  }
}

import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_not_sepeti/models/kategori.dart';
import 'package:flutter_not_sepeti/not_detay.dart';
import 'package:flutter_not_sepeti/utils/database_helper.dart';
import 'kategori_islemleri.dart';
import 'models/notlar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var data = DatabaseHelper();
    data.kategorileriGetir();
    return MaterialApp(
      title: 'Not Sepeti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NotListesi(),
    );
  }
}

class NotListesi extends StatelessWidget {
  DatabaseHelper databaseHelper = DatabaseHelper();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Center(
          child: Text("Not Sepeti"),
        ),
          actions: [
            PopupMenuButton(itemBuilder: (context){
              return [
                PopupMenuItem(child: ListTile(leading: Icon(Icons.category),title: Text("Kategoriler"),onTap:(){
                  Navigator.pop(context);
                  _kategorilerSayfasi(context);
                }),),
              ];
            }),
          ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              kategoriEkleDialog(context);
            },
            heroTag: "KategoriEkle",
            tooltip: "Kategori Ekle",
            child: Icon(Icons.add_circle),
            mini: true,
          ),
          FloatingActionButton(
            onPressed: () => _detaySayfasi(context),
            heroTag: "NotEkle",
            tooltip: "Not Ekle",
            child: Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(child: Not()),
    );
  }

  void kategoriEkleDialog(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    String yeniKategori;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Kategori Ekle",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            children: [
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onSaved: (yeniDeger) {
                      yeniKategori = yeniDeger;
                    },
                    decoration: InputDecoration(
                      labelText: "Kategori Adı",
                      border: OutlineInputBorder(),
                    ),
                    // ignore: missing_return
                    validator: (girilenKategoriAdi) {
                      if (girilenKategoriAdi.length < 1) {
                        return "En az 1 karakter gerek";
                      }
                    },
                  ),
                ),
              ),
              ButtonBar(
                children: [
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.orangeAccent,
                    child: Text(
                      "Vazgeç",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {
                      if (formKey.currentState.validate()) {
                        Navigator.pop(context);
                        formKey.currentState.save();
                        databaseHelper
                            .kategoriEkle(Kategori(yeniKategori))
                            .then((kategoriID) {
                          if (kategoriID > 0) {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text("Kategori Eklendi"),
                              duration: Duration(seconds: 2),
                            ));
                          }
                        });
                      }
                    },
                    color: Colors.green.shade300,
                    child: Text(
                      "Kaydet",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  _detaySayfasi(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NotDetay(
                  baslik: "Yeni Not",
                )));
  }

  _kategorilerSayfasi(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => Kategoriler()));
  }
}

class Not extends StatefulWidget {
  @override
  _NotState createState() => _NotState();
}

class _NotState extends State<Not> {
  List<Notlar> tumNotlar;
  DatabaseHelper databaseHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumNotlar = List<Notlar>();
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: FutureBuilder(
        future: databaseHelper.notListesi(),
        builder: (context, AsyncSnapshot<List<Notlar>> snapShot) {
          if (snapShot.connectionState == ConnectionState.done) {
            tumNotlar = snapShot.data;
            sleep(Duration(milliseconds: 500));
            return ListView.builder(
                itemCount: tumNotlar.length,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    leading: _oncelikIconu(tumNotlar[index].notOncelik),
                    title: Text(tumNotlar[index].notBaslik),
                    subtitle: Text(tumNotlar[index].kategoriBaslik),
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Oluşturma Tarihi: ",style: TextStyle(color: Colors.blueAccent.shade400),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(databaseHelper.dateFormat(DateTime.parse(tumNotlar[index].notTarih)),style: TextStyle(color: Colors.blueAccent.shade400),),
                                )
                              ],
                            ),
                            Divider(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(tumNotlar[index].notIcerik),
                            ),
                            ButtonBar(
                              children: [
                                FlatButton(onPressed: ()=>_notSil(tumNotlar[index].notID), child: Text("SİL",style: TextStyle(color: Colors.redAccent.shade400),),),
                                FlatButton(onPressed: (){
                                  _detaySayfasi(context, tumNotlar[index]);
                                }, child: Text("GÜNCELLE",style: TextStyle(color: Colors.blueGrey),),),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                });
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  _detaySayfasi(BuildContext context, Notlar not) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NotDetay(
              baslik: "Notu Düzenle",
              duzenlenecekNot : not,
            )));
  }

  _oncelikIconu(int notOncelik) {
    switch(notOncelik){
      case 0:
        return CircleAvatar(child: Text("AZ"),backgroundColor: Colors.blueGrey.shade100,);
        break;
      case 1:
        return CircleAvatar(child: Text("ORTA"),backgroundColor: Colors.blueGrey.shade100,);
        break;
      case 2:
        return CircleAvatar(child: Text("ACİL"),backgroundColor: Colors.blueGrey.shade100,);
        break;
    }
  }

  _notSil(int notID) {
    databaseHelper.notSil(notID).then((silinenID){
      if(silinenID!=0){
        Scaffold.of(context).showSnackBar(SnackBar(content: Text("Not Silindi"),));
        setState(() {});
      }
    });
  }
}

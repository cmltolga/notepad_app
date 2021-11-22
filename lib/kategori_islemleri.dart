import 'package:flutter/material.dart';
import 'package:flutter_not_sepeti/models/kategori.dart';
import 'package:flutter_not_sepeti/utils/database_helper.dart';

class Kategoriler extends StatefulWidget {
  @override
  _KategorilerState createState() => _KategorilerState();
}

class _KategorilerState extends State<Kategoriler> {
  List<Kategori> tumKategoriler;
  DatabaseHelper databaseHelper;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    databaseHelper=DatabaseHelper();
  }
  @override
  Widget build(BuildContext context) {
    if(tumKategoriler== null){
      tumKategoriler =List<Kategori>();
      kategoriListGuncelle();
    }
    return Scaffold(
      appBar: AppBar(title: Text("Kategoriler"),),
      body: ListView.builder(itemCount: tumKategoriler.length,itemBuilder: (context,index){
        return ListTile(
          onTap: ()=>_kategoriGuncelle(tumKategoriler[index],context),
          title: Text(tumKategoriler[index].kategoriBaslik),
          trailing: InkWell(child: Icon(Icons.delete),onTap:()=> _kategoriSil(tumKategoriler[index].kategoriID),),
          leading: Icon(Icons.category),
        );
      }),
    );
  }

  void kategoriListGuncelle() {
    databaseHelper.kategoriListesiniGetir().then((kategoriList){
      setState(() {
        tumKategoriler=kategoriList;
      });
    });
  }

  _kategoriSil(int kategoriID) {
    showDialog(context: context,barrierDismissible: false,builder:(context){
      return AlertDialog(title: Text("Emin Misiniz?"),content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Kategoriyi Sildiğinizde bununla ilgili tüm notlar da silinecektir..."),
          ButtonBar(
            children: [
              FlatButton(onPressed: (){
                Navigator.of(context).pop();
              },child: Text("Vazgeç"),),
              FlatButton(onPressed: (){
                databaseHelper.kategoriSil(kategoriID).then((silinenKategori){
                  if(silinenKategori!=0){
                    kategoriListGuncelle();
                    Navigator.of(context).pop();
                  }
                });
              },child: Text("Kategoriyi sil"),),
            ],
          ),
        ],
      ),);
    });
  }

  _kategoriGuncelle(Kategori guncellenecekKategori,BuildContext c) {
    kategoriGuncelleDialog(c,guncellenecekKategori);
  }
  void kategoriGuncelleDialog(BuildContext myContext,Kategori guncellenecekKategori) {
    var formKey = GlobalKey<FormState>();
    String guncellenecekKategoriAdi;
    showDialog(
        barrierDismissible: false,
        context: myContext,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Kategori Güncelle",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            children: [
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    initialValue: guncellenecekKategori.kategoriBaslik,
                    onSaved: (yeniDeger) {
                      guncellenecekKategoriAdi = yeniDeger;
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
                        databaseHelper.kategoriGuncelle(Kategori.withID(guncellenecekKategori.kategoriID, guncellenecekKategoriAdi)).then((katID){
                          if(katID!=0){
                            Scaffold.of(myContext).showSnackBar(SnackBar(
                              content: Text("Kategori Güncellendi"),
                              duration: Duration(seconds: 2),
                            ));
                          }
                        });
                        setState(() {
                          kategoriListGuncelle();
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

}

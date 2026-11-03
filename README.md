# Flutter Feature Lab — ProjeDosya

Flutter ile müşteri ve proje dosyalarını düzenlemek için yerel uygulama.

## Hızlı başlangıç

Flutter 3.47+ / Dart 3.13+ ve Git gerekir. Flutter SDK repoya dahil değildir.

```sh
git clone https://github.com/huseyinkalemkas/flutter-feature-lab.git
cd flutter-feature-lab
flutter pub get
dart run build_runner build
flutter run -d chrome
```

Windows'ta Flutter PATH üzerinden veya yerel `.tools/flutter` kurulumundan bulunur. `./start.ps1` release sürümünü normal Edge profilinde açar. Android için Android SDK; iOS için macOS ve Xcode gerekir.

## Kullanım

### Ortak üst kontrol bandı

Tüm ekranlarda sabit bir üst bant vardır. Projeler, sayfalama, animasyon, Sync/Async, Hive, Shared Preferences, SQLite, route örnekleri ve profil kısayolları burada toplanmıştır. Yeni proje, müşteri ekleme, router ve geçiş efekti seçimi de aynı alandadır. Geri düğmesi her zaman görünür; dar ekranlarda diğer düğme satırları yatay kaydırılır.

Ağ durum rozeti sürekli görünür ve tıklanarak yeniden kontrol edilir. Ayrıntılı `MaterialBanner` ağ mesajı aynı üst alanın altında açılır. Ayarlar üst sağ köşededir. Dosya düzenleme ve oynatma gibi içerik işlemleri ilgili ekranda kalır.

1. **Müşteri ekle** ile müşteri adını ve isteğe bağlı iletişim bilgisini kaydedin.
2. **Yeni proje** ile müşteriye bağlı proje oluşturun.
3. Proje içinde **Dosya seç ve aç** ile PDF, fotoğraf veya ses kaydı ekleyin.
4. Dosya ekranında yıldızla favoriye alın; not simgesinden adını ve notunu düzenleyin.
5. Projelerde müşteri/arama/durum, dosyalarda tür/arama/favori filtrelerini kullanın.
6. Projeyi tamamlandı olarak işaretleyin veya yeniden açın.

Dosya ekranındaki menüden bağlantı kopyalanabilir ve dosya onay verildikten sonra silinebilir.

## Çalıştırma (Windows)

Bu bilgisayarda Flutter SDK `.tools/flutter` altında bulunur.

```powershell
.\start.ps1
```

Başlatıcı release web derlemesini yapar ve **http://localhost:7357** adresini normal Edge profilinde uygulama penceresi olarak açar. Terminali açık tutun; durdurmak için Ctrl+C. Son derlemeyi tekrar kullanmak için:

```powershell
.\start.ps1 -SkipBuild
```

Geliştirme için:

```powershell
.\flutter.ps1 run -d edge
```

Flutter'ın geliştirme tarayıcısı geçici profil kullanabilir. Günlük kullanımda `.\start.ps1` ve aynı tarayıcı profilini kullanın. Başlatıcı sabit adres kullanır; farklı host/port veya profil ayrı bir yerel arşivdir.

## Saklama ve kapsam

Hive CE kullanılır: web'de IndexedDB, mobilde uygulamanın yerel deposu. Müşteri, proje, dosya içeriği, not ve favoriler kayıt işlemi tamamlandıktan sonra kalıcıdır. Önceki örnekteki son 5 dosya sınırı kaldırılmıştır. Dosya başına 20 MB sınırı vardır. Kapasite cihaz/tarayıcı depolamasına bağlıdır; depolama hataları kullanıcıya gösterilir.

Bu sürüm tek cihazda kullanım içindir. Hesap, sunucuya yükleme, takım erişimi, otomatik yedekleme veya cihazlar arası eşitleme içermez. Tarayıcı/site verilerinin silinmesi yerel arşivi de siler. Dosya bağlantısı sadece ilgili dosyanın saklandığı aynı arşivde açılır.

Desteklenen türler: PDF; JPG/JPEG/PNG/WebP/GIF; MP3/WAV/M4A/OGG. Fotoğrafta yakınlaştırma, PDF'de görüntüleme, seste oynat/duraklat/durdur vardır. Ses codec desteği cihaz ve tarayıcıya bağlıdır.

## Ağ kontrolü ve MaterialBanner

Üretim başlangıcında `NetworkMonitor.live()` internet erişimini `internet_connection_checker_plus` ile kontrol eder. Ağ türü yerine HTTPS kontrol noktalarına erişim doğrulanır; uygulama ön plandayken yaklaşık 5 saniyede bir değişimler izlenir. Android release manifestine `INTERNET` izni eklenmiştir.

- Kontrol sırasında üstte yükleme banner'ı gösterilir.
- Erişim doğrulanamazsa sarı `MaterialBanner` kalır; **Tekrar dene** ile anında kontrol yapılır.
- Erişim geri geldiğinde yeşil banner gösterilir; 4 saniye sonra kapanır veya **Kapat** kullanılabilir.
- Kontrol başarısız/zaman aşımında belirsiz durum mesajı gösterilir.
- **Ayarlar → İnternet bağlantısı** bölümünden durum görülebilir ve kontrol yeniden başlatılabilir.

Banner tüm route'larda ve iki router'da ortaktır. Yerel kayıtlar ağ yokken kullanılabilir; dosyalar bu kontrol sırasında gönderilmez. Kontrol noktalarının engellenmesi de erişimin doğrulanamamasına neden olabilir; tek bir bağlantı sonucu bütün servislerin erişilebilir olduğunu garanti etmez. Kaynak: `lib/network.dart`. [Paket belgeleri](https://pub.dev/packages/internet_connection_checker_plus).

## Ekranlar ve yönlendirme

### Sayfalı proje listesi

Ana sayfanın üstündeki **Sayfalı liste** simgesi `/project-list` ekranını açar. Sayfa başına 5/10/20 kayıt, sayfa numaraları ve önceki/sonraki kontrolleri bulunur. Proje veya müşteri araması ilk sayfaya döner; kayıt sayısı değişince sayfa da sıfırlanır. `page`, `size`, `q`, `demo` parametreleri URL'de korunur ve iki router ile çalışır.

**Örnek verilerle dene** seçeneği 53 geçici kayıt gösterir; arşivi değiştirmez. Örnek adres: `http://localhost:7357/#/project-list?page=2&size=5&demo=true`. Sayfalama mevcut yerel projeler üzerinde yapılır; sunucu/API isteği değildir.

**Liste / Grid** seçicisi görünümü değiştirir. Grid, ekran genişliğine göre 1–3 sütundur. Görünüm değişiminde sayfa, arama ve kayıt sayısı korunur; `view=list` veya `view=grid` URL parametresiyle yenilemede ve router değişiminde de aynı görünüm açılır.

### Lazy loading ve yükleme görünümleri

**Sayfalı / Lazy loading** seçicisinden kaydırarak yüklemeye geçin. Listenin altına yaklaşınca sıradaki 5/10/20 kayıt eklenir; **Daha fazla yükle** düğmesi de aynı işi yapar. Liste ve grid, SliverList/SliverGrid builder'larıyla ekranın ihtiyaç duyduğu kartları oluşturur. **Standart / Skeleton** seçimi, ilk yükleme ve yeni gruplarda spinner veya nabız animasyonlu iskelet kartlar gösterir. Hatalarda yeniden deneme vardır; eski arama yanıtları yeni sonuçları değiştiremez.

`load=lazy&loading=skeleton` veya `load=lazy&loading=standard` URL parametrelerini kullanabilirsiniz. Lazy moda girişte ilk gruptan başlanır; eklenen gruplar bu ekran oturumunda tutulur. Yerel arşivde yapay bekleme yoktur. Örnek kayıtlarda yükleme görünümünü denemek için açıkça belirtilen 650 ms gecikme uygulanır. Veri kaynağı yerel proje metadata deposudur; uzaktaki API'ye bağlanmaz.

### Animasyon stüdyosu ve 3B geçişler

Ana sayfadaki animasyon simgesinden veya **Ayarlar → Animasyon stüdyosunu aç** ile `/animation-lab` ekranına ulaşın.

- `AnimationController`: oynat, duraklat, tersine oynat, sıfırla, ilerleme çubuğu, hız (0.5x–2x) ve döngü.
- `Tween<double>`: 3B kartın dönüş açısı, ölçeği ve konumu.
- `CurvedAnimation`: linear, easeInOutCubic ve elasticOut eğrileri.
- `AnimatedContainer`: boyut, renk ve köşe yuvarlaklığı değişimi.
- Lottie JSON: `assets/animations/project_ready.json` içindeki bu proje için oluşturulmuş yerel klasör/evrak animasyonu. Ağdan dosya indirmez, ayrı bir controller ile oynatılır.

**Gerçek route geçişini dene** bölümünden 3B kart dönüşü, küp veya derinlik seçip `/animation-preview` sayfasına geçin. Seçilen efekt uygulama tercihi olarak kaydedilir; geri dönüşte ters yönde uygulanır. Bu efektler iki router'da ortak `Matrix4` perspektif dönüşümü kullanır. Sistem animasyon azaltma tercihi etkinse otomatik oynatma ve route efektleri kapatılır.

Kaynak: `lib/animation_lab.dart`, `lib/motion.dart`. Paket: [Lottie Flutter](https://pub.dev/packages/lottie).

**Ayarlar → Sayfa geçiş efekti** bölümünde 3B efektlere ek olarak Kayma + solma, Solma ve Efekt yok seçenekleri de bulunur. İki router'da ortak geçiş kullanılır, tercih yerelde saklanır. Yeni kartlar kısa solma efektiyle görünür. Sistem animasyon azaltma tercihi varsa geçiş ve skeleton animasyonları kapatılır.

**Ayarlar → Yönlendirme motoru** ile `go_router` ve `auto_route` seçilir. Motor değişince açık proje/dosya korunur. Uygulama yeniden açıldığında varsayılan motor `auto_route` olur.

- `/`: müşteri ve proje çalışma alanı
- `/projects/:projectId`: projeye ait dosyalar
- `/media/:id`: dosya görüntüleyici
- `/demo`: önceki ürün/profil/parametre örneği (Ayarlar içinden açılır)

Örnek native bağlantı: `linkdemo://app/projects/PROJE_ID` veya `linkdemo://app/media/DOSYA_ID`. Web'de `http://localhost:7357/#/media/DOSYA_ID`.

`auto_route` üretilen route sınıflarıyla, `go_router` URL ve `extra` ile geçiş yapar. Kalıcı dosya ID'si üzerinden arşivden de okunur. Route veya sayfa parametreleri değişirse:

```powershell
.\.tools\flutter\bin\dart.bat run build_runner build
```

## Android / iOS

Platform ayarları projede bulunur. Gerekirse `.\setup.ps1` platform dosyalarını ve route sınıflarını hazırlar. Android SDK/cihaz, iOS için macOS/Xcode gerekir. iOS alt sınırı 15.0'dır. Native PDF paketlerinin derleme araçları da gerekir. Bu ortamda Android/iOS derlemesi yapılmamıştır.

```sh
adb shell am start -W -a android.intent.action.VIEW -d 'linkdemo://app/projects/PROJE_ID' com.example.deep_link_demo
xcrun simctl openurl booted 'linkdemo://app/projects/PROJE_ID'
```

HTTPS App Links/Universal Links için `example.com` yer tutucusunu kendi alan adınızla değiştirin; Android assetlinks.json ve iOS Associated Domains/AASA doğrulamasını tamamlayın. Custom scheme ayarları hazırdır.

## Kaynaklar ve doğrulama

- `lib/main.dart`: başlangıç, router seçimi, route tanımları ve dosya ekranı
- `lib/workspace.dart`: müşteri/proje arayüzü ve dosya düzenleme
- `lib/storage.dart`: kalıcı depo ve müşteri/proje modelleri
- `lib/media.dart`: dosya okuma, dosya modeli ve görüntüleyiciler
- `tool/serve.dart`: yerel web başlatıcısı

```powershell
.\flutter.ps1 analyze
.\flutter.ps1 test
.\flutter.ps1 build web --release
```

47 test geçmiştir: müşteri/proje oluşturma, dosya aktarımı, iki router arasında geçiş, favori/not, proje durumu, bounded stream okuma ve depo yeniden açıldığında kalıcılık. PDF render ve ses codec davranışı gerçek cihaz/tarayıcıda kendi dosyalarınızla da doğrulanmalıdır.

Paket belgeleri: [auto_route](https://pub.dev/packages/auto_route), [go_router](https://pub.dev/packages/go_router), [Hive CE](https://pub.dev/packages/hive_ce), [file_picker](https://pub.dev/packages/file_picker), [pdfrx](https://pub.dev/packages/pdfrx), [audioplayers](https://pub.dev/packages/audioplayers).

## Sade depolama örnekleri

Ana sayfadaki **Yerel depolama örnekleri** bölümünden üç ayrı sayfa açılır. Her iki yönlendirme motorunda da aynı adresler kullanılır:

- `/hive-example`: Hive CE ile not ekleme, listeleme ve silme.
- `/preferences-example`: SharedPreferencesAsync ile kullanıcı adı ve bildirim tercihini kaydetme/okuma.
- `/sqlite-example`: sqflite ile görev ekleme, tamamlama ve silme.

Örnekler `lib/storage_examples.dart` içindedir. Her sayfa kendi deposunu kullanır ve kısa bir kod örneği gösterir. Mobilde SQLite için sqflite, webde sqflite_common_ffi_web kullanılır. Web için gerekli `web/sqlite3.wasm` ve `web/sqflite_sw.js` dosyaları eklenmiştir. SQLite paketini güncellerken bunları yeniden üretin:

```powershell
.\flutter.ps1 pub run sqflite_common_ffi_web:setup --force
```

Paket belgeleri: [Shared Preferences](https://pub.dev/packages/shared_preferences), [sqflite](https://pub.dev/packages/sqflite), [SQLite web desteği](https://pub.dev/packages/sqflite_common_ffi_web).

## Stream ve StreamBuilder örneği

Üst gezinme menüsündeki **Stream / StreamBuilder**, `/stream-example` sayfasını açar. `lib/stream_example.dart` içindeki sayaç her saniye bir `Stream<int>` olayı gönderir. StreamBuilder ekranda son veriyi, `connectionState`, `hasData` ve `hasError` durumlarını gösterir. Başlat, Duraklat, Hata gönder, Akışı bitir ve Sıfırla düğmeleriyle veri, hata ve tamamlanma durumları denenebilir. Sayfa kapanırken zamanlayıcı iptal edilir ve controller kapatılır.

Belgeler: [StreamBuilder](https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html), [StreamController](https://api.dart.dev/dart-async/StreamController-class.html).

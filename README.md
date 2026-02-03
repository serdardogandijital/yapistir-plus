# Yapıştır+ (YapistirPlus)

macOS için hızlı metin yapıştırma uygulaması. Hazır metinlerinizi kısayollarla anında yapıştırın.

![Yapıştır+ Screenshot](screenshot.png)

## Özellikler

- **Kısayollarla Yapıştır**: Option (⌥) + 1, 2, 3... ile hazır metinleri anında yapıştırın
- **Kolay Düzenleme**: Menü çubuğundan metinlerinizi ekleyin, düzenleyin, silin
- **Hafif**: Sadece ~100KB, sistem kaynaklarını yormaz
- **Türkçe Arayüz**: Tamamen Türkçe kullanıcı arayüzü

## Kurulum

### DMG ile Kurulum (Önerilen)

1. [Releases](https://github.com/serdardogan/yapistir-plus/releases) sayfasından `YapistirPlus.dmg` dosyasını indirin
2. DMG dosyasını açın
3. `Yapıştır+` uygulamasını `Applications` klasörüne sürükleyin
4. Uygulamayı açın

### Kaynak Koddan Derleme

```bash
git clone https://github.com/serdardogan/yapistir-plus.git
cd yapistir-plus
swift build -c release
```

## İlk Kullanım

1. Uygulamayı açtığınızda menü çubuğunda (sağ üstte) clipboard ikonu görünecek
2. **Accessibility izni** verin:
   - System Settings → Privacy & Security → Accessibility
   - Yapıştır+ uygulamasını etkinleştirin
3. İkona tıklayarak metinlerinizi düzenleyin
4. **Option + 1, 2, 3...** ile yapıştırın

## Kullanım

| Kısayol | İşlev |
|---------|-------|
| ⌥ + 1 | 1. metni yapıştır |
| ⌥ + 2 | 2. metni yapıştır |
| ⌥ + 3 | 3. metni yapıştır |
| ... | ... |
| ⌥ + 9 | 9. metni yapıştır |

## Sistem Gereksinimleri

- macOS 13.0 (Ventura) veya üzeri
- Apple Silicon veya Intel işlemci

## Geliştirici

**Serdar DOĞAN**
- Web: [serdardogan.com.tr](https://serdardogan.com.tr)
- GitHub: [@serdardogandijital](https://github.com/serdardogandijital)

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

⭐ Beğendiyseniz yıldız vermeyi unutmayın!

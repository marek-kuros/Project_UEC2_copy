# UEC2 Projekt - gra ping-pong
Gra została stworzona wykorzystując **płytkę deweloperską z FPGA Xilinx Artix 7-FPGA _Basys3_ :mechanical_arm:** <br/>
<sub>przykład na zdjęciu poniżej :point_down:</sub><br/>
<!--<sup>jej, pisząc to czuję się jakbym wrócił do html+css</sup>-->
![basys3 - przykładowa płytka](/doc/basys3_picture.jpg)

Do rozpoczęcia rozgrywki należy podpiąć ekran o rozdzielczości oraz odświeżaniu conajmniej 1024x768@60Hz <br/>
wraz z myszką. <br/>

Po włączeniu, gra wita nas ekranem głównym gdzie wyświetlone są opcje rozgrywki <br/>
* `Tryb singleplayer` :technologist:
* `Tryb Multiplayer`  :technologist::technologist: <br/>

W celu wybrania trybu gry należy odpowiednio przesunąć przełącznik "sw[0] lub sw[1]" w stan **HIGH**. 
Jeżeli ustwaimy "sw[0]" jako **HIGH**, to przejdziemy do trybu singleplayer natomiast w przypadku "sw[1]" jako **HIGH**, załączymy tryb multiplayer. Jeżeli niechcący przełączymy obydwa przełączniki to gra zostanie w ekranie startowym. Warto nadmienić, iż w każdy momencie możemy wyjść z danego trybu gry przełączając przełącznik w stan **LOW**. <br/>
Celem rozpoczęcia gry w którymkolwiek trybie należy najpierw zaserwować piłeczkę, wykonujemy to guzikiem btnR (piłeczka zaczyna lecieć w randomową stronę - 20% prawdopodobieństaw, że poleci prostopadle do lini paletek oraz po 15%, żę poleci pod skosem). <br/>

! Przycisk btnC jest wykorzystywany jako reset.

## Opis trybu singleplayer
Tryb singleplayer polega na jak najdłuższym odbijaniu piłeczki, trudność polegana tym, że druga paletka porusza się odwrtonie do pierwszej :scream_cat:. W przypadku kiedy piłeczka wyleci, na siedmiosegmentowym ekranie pojawi się kod 0101, a następnie piłeczka zniknie sygnalizując przegraną.
## Opis trybu multiplayer
Tryb multiplayer to klasyczny przykład gry w ping-ponga :ping_pong:. Wygrywa osoba, która zdobędzie 11 punktów.

## 
### _Po zakończonej grze można ją zresetować ponownie serwując piłeczkę._

<sub>Elementy na płytce, z których korzysta gra :point_down:</sub>
![basys3 - ważniejsze elementy wykorzystane do gry](/doc/basys3_picture_howtoplay.png)

## Dodatkowe opcje rozgrywki
### Gamepad niczym prawdziwa paletka :scream_cat:!
Do wykonania paletki potrzeba:
* esp8266 wraz z wgranym micropythonem (ścieżka do przykładowego kodu - additional_files/gamepad_ping-pong.py) - 
[Quick reference for the ESP8266](https://docs.micropython.org/en/latest/esp8266/quickref.html#)
![esp8266](https://m.media-amazon.com/images/I/71UyYP0vEHL._AC_UF1000,1000_QL80_.jpg)
* akcelerometr adxl345
![adxl345](https://kamami.pl/34556-large_default/module-with-adxl345-accelerometer.jpg)
* kable do połączenia
![kable goldpin](https://cdn1.botland.com.pl/104345/przewody-polaczeniowe-mesko-meskie-justpi-10cm-40szt.jpg)

## Klonowanie repozytorium

```bash
git clone https://github.com/marek-kuros/Project_UEC2.git
```

**Wszystkie komendy należy wywoływać z głównego folderu projektu** (w tym wypadku `Project_UEC2`).\
_Każdy plik w projekcie posiada nagłówek z krótkim opisem jego funkcji._

## Inicjalizacja środowiska

Aby rozpocząć pracę z projektem, należy uruchomić terminal w folderze projektu i zainicjalizować środowisko:

```bash
. env.sh
```

Następnie, pozostając w głównym folderze, można wywoływać dostępne narzędzia:

* `run_simulation.sh`
* `generate_bitstream.sh`
* `program_fpga.sh`
* `clean.sh`

Narzędzia te zostały opisane poniżej.

## Uruchamianie symulacji

Symulacje uruchamia się skryptem `run_simulation.sh`.

### Przygotowanie testu

Aby skrypt poprawnie uruchomił symulacje, zawrtość testu musi zostać przygotowana zgodnie z poniższym opisem:

* w folderze `sim` należy utworzyć folder, którego nazwa będzie nazwą testu
* w folderze testu należy umieścić:
  * plik o tej samej nazwie, co nazwa testu, z rozszerzeniu `.prj`
  * plik o tej samej nazwie, co nazwa testu, z dopiskiem `_tb.sv`

Przykładowa struktura:

```text
├── sim
│   ├── and2
│   │   ├── and2.prj
│   │   ├── and2_tb.sv
│   │   └── jakis_pomocniczy_modul_do_symulacji.v
```

W pliku `.prj` należy umieścić ścieżki do plików zawierających moduły używane w symulacji. Ścieżki te muszą zostać podane względem lokalizacji pliku `.prj`. Przykładowa zawartość pliku `.prj` wygląda następująco:

```properties
sv      work  and2_tb.sv \
              ../../rtl/and2.sv
verilog work  jakis_pomocniczy_modul_do_symulacji.v
vhdl    work  ../../rtl/jakis_modul_w_vhdl.vhd
```

* pierwsze słowo określa język, w ktorym napisano moduł
* drugie - bibliotekę (tutaj należy zostawić `work`)
* trzecie i kolejne - ścieżki do plików (w przypadku vhdl należy podawać po jednym pliku na linię).

Jeśli któryś z modułów importuje pakiet (_package_), to ścieżka do pakietu powinna pojawić się na liście przed ścieżkami do modułów.

Jeśli w symulowanych modułach znajdują się bloki IP, to do pliku `.prj` należy dopisać poniższą linijkę:

```properties
verilog work ../common/glbl.v
```

W pliku `<nazwa_testu>_tb.sv` należy napisać moduł testowy. Nazwa modułu musi być taka sama, jak nazwa testu. (W ogóle należy przyjąć zasadę, że nazwa pliku powinna być identyczna jak nazwa modułu, który w nim zdefiniowano.)

### Dostępne opcje skryptu `run_simulation.sh`

* Wyświetlenie listy dostępnych testów

  ```bash
  run_simulation.sh -l
  ```

* Uruchamianie symulacji w trybie tekstowym

  ```bash
  run_simulation.sh -t <nazwa_testu>
  ```

* Uruchamianie symulacji w trybie graficznym

  ```bash
  run_simulation.sh -gt <nazwa_testu>
  ```

* Uruchamianie wszystkich symulacji

  ```bash
  run_simulation.sh -a
  ```

  W tym trybie, po kolei uruchamiane są wszystkie symulacje dostępne w folderze `sim`, a w terminalu wyświetlana jest informacja o ich wyniku:

  * PASSED - jeśli nie wykryto żadnych błędów,
  * FAILED - jeśli podczas symulacji wykryto błędy (w logu przynajmniej raz pojawiło się słowo _error_).

  Aby test działał poprawnie, należy w testbenchu stosować **asercje**, które w przypadku niespełnienia warunku zwrócą `$error`.

## Generowanie bitstreamu

```bash
generate_bitstream.sh
```

Skrypt ten uruchamia generację bitstreamu, który finalnie znajdzie się w folderze `results`. Następnie sprawdza logi z syntezy i implementacji pod kątem ewentualnych ostrzeżeń (_warning_, _critical warning_) i błędów (_error_), a w razie ich wystąpienie kopiuje ich treść do pliku `results/warning_summary.log`

## Wgrywanie bitstreamu do Basys3

```bash
program_fpga.sh
```

Aby skrypt poprawnie wgrał bitstream do FPGA, w folderze `results` musi znajdować się **tylko jeden** plik z rozszerzeniem `.bit`.

## Sprzątanie projektu

```bash
clean.sh
```

Zadaniem tego skryptu jest usunięcie wszystkich plików tymczasowych wygenerowanych wskutek działania narzędzi. Pliki te muszą być wymienione w `.gitignore`, a w projekcie musi być zainicjalizowane repozytorium git (inicjalizację tę wykonuje `env.sh`).

Ponadto, skrypty do symulacji oraz generacji bitstreamu, przy każdym ich uruchomieniu (o ile w projekcie zainicjalizowane jest repozytorium git), kasują wyniki poprzednich operacji przed uruchomieniem nowych.

## Uruchamianie projektu w Vivado w trybie graficznym

Aby otworzyć w Vivado w trybie graficznym zbudowany projekt (tzn. po zakończeniu działania `generate_bitstream.sh`), należy przejść do folderu `fpga/build` i wywołać w nim komendę:

```bash
vivado <nazwa_projektu>.xpr
```

## W razie niepowodzenia symulacji lub generacji bitstreamu

Jeśli symulacja lub generacji bitstreamu nie przebiega poprawnie, należy szukać przyczyny czytając w terminalu log, ze szczególnym uwzględnieniem linijek zawierających _ERROR_. Często najcenniejszą informację znajdziemy szukając pierwszego wystąpienia _ERROR_a.

Jeśli po uruchomienie narzędzia, w terminalu wyświetla się:

```bash
Vivado%
```

oznacza to, że skrypt poprawnie uruchomił Vivado w trybie tekstowym, ale prawdopodobnie wystąpił błąd w plikach źródłowych, lub w ogóle ich nie znaleziono. Aby zamknąć Vivado wystarczy wpisać w terminalu

```tcl
exit
```

Jeśli uważne przeglądnięcie logów nie przyniosło rozwiązania, można spróbować, zamiast zamykania Vivado, uruchomić tryb graficzny i przeglądnąć widzianą przez program zawartość projektu. Wówczas, widząc napis `Vivado%`, należy wpisać w terminalu:

```tcl
start_gui
```

Jeśli potrzebujemy ptrzerwać uruchomiony proces, możemy skorzytać z kombinacji <kbd>Ctrl</kbd>+<kbd>C</kbd>.

## Struktura projektu

Poniżej przedstawiono hierarchię plików w projekcie. Aby wszystkie narzędzia działały poprawnie, należy jej przestrzegać.

```text
.
├── env.sh                         - konfiguracja środowiska
├── fpga                           - pliki związane z FPGA
│   ├── constraints                - * pliki xdc
│   │   └── top_vga_basys3.xdc
│   ├── rtl                        - * syntezowalne pliki związane z FPGA
│   │   └── top_vga_basys3.sv      - * * moduł instancjonujący nadrzędny moduł projektu rtl/top* oraz bloki
│   │                                    specyficzne dla FPGA (np. bufory lub sentezator częstotliwości zegara)
│   └── scripts                    - * skrypty tcl (uruchamiane odpowiednimi narzędziami z tools)
│       ├── generate_bitstream.tcl
│       ├── program_fpga.tcl
│       └── project_details.tcl    - * * informacje o nazwie projektu, module top i plikach do syntezy
├── README.md                      - ten plik
├── results                        - pliki wynikowe generacji bitstreamu
│   ├── top_vga_basys3.bit         - * bitstream
│   └── warning_summary.log        - * podsumowanie ostrzeżeń i błędów
├── rtl                            - syntezowalne pliki projektu (niezależne od FPGA)
│   ├── draw_bg.sv
│   ├── top_vga.sv                 - * moduł nadrzędny (top)
│   ├── vga_pkg.sv                 - * pakiet zawierający stałe używane w projekcie
│   └── vga_timing.sv
├── sim                            - folder z testami
│   ├── common                     - * pliki wspólne dla wielu testów
│   │   └── glbl.v                 - * * plik potrzebny do symulacji z IP corami; tworzony przy wywołaniu env.sh
│   │   └── tiff_writer.sv
│   ├── top_fpga                   - * folder pojedynczego testu
│   │   ├── top_fpga.prj           - * * lista plików z modułami używanymi w teście
│   │   └── top_fpga_tb.sv         - * * kod testbenchu
│   ├── top_vga
│   │   ├── top_vga.prj
│   │   └── top_vga_tb.sv
│   └── vga_timing
│       ├── vga_timing.prj
│       └── vga_timing_tb.sv
└── tools                          - narzędzia do pracy z projektem
    ├── clean.sh                   - * czyszczenie plików tymczasowych
    ├── generate_bitstream.sh      - * generacja bitstreamu (uruchamia też warning_summary.sh)
    ├── program_fpga.sh            - * wgrywanie bitstreamu do FPGA
    ├── run_simulation.sh          - * uruchamianie symulacji
    ├── sim_cmd.tcl                - * komedy tcl używane przez run_simulation.sh (nie należy wywoływać samodzielnie)
    └── warning_summary.sh         - * filtrowanie ostrzeżeń i błędów z generacji bitstreamu (wynik w results)
```

### Folder **fpga**

W tym folderze znajdują się pliki powiązane stricte z FPGA. Plik `fpga/rtl/top_*_basys3.sv` zawiera instancję funkcjonalnego topa projektu (`rtl/top*.sv`) oraz bloki IP specyficzne dla FPGA. Pozwala również zrealizować mapowanie funkcjonalnych portów projektu na fizyczne wyprowadzenia na PCB, np:

```sv
.rst(btnC),
.ready(led[0])
```

W pliku `fpga/scripts/project_details.tcl` należy podać nazwę projektu, nazwę głównego modułu (top fpga) oraz ścieżki do wszystkich plików zawierających moduły używane do syntezy. Ścieżki te należy podawać **względem lokalizacji folderu `fpga`** (a nie względem pliku _.tcl_).

### Folder **rtl**

Tutaj znajdują się syntezowalne pliki projektu, nie powiązane bezpośrednio z FPGA. Wśród nich znajduje się moduł nadrzędny (_top_), który powinien mieć budowę wyłącznie strukturalną (tzn. powinien zawierać instancje modułów podrzędnych i łączyć je ze sobą _wire_-ami, a nie powinien zawierać żadnych bloków _always_). W miarę przybywania plików w folderze `rtl`, warto rozważyć utworzenie podfolderów w celu grupowania powiązanych ze sobą tematycznie plików.

## Weryfikacja poprawności napisanego kodu

Do sprawdzenia poprawności napisanego kodu w języku SystemVerilog na serwerze studenckim i stacjach roboczych w laboratorium P014 należy skorzystać ze skonfigorwanego w tym celu narzędzia _Cadence HDL analysis and lint tool (HAL)_.

Aby sprawdzić kod pod kątem syntezy należy wywołać polecenie:

```
hal_mtm_rtl.sh <ścieżki do sprawdzanego pliku i plików zależnych>
```

Aby sprawdzić kod pod kątem symulacji należy wywołać polecenie:

```
hal_mtm_tb.sh <ścieżki do sprawdzanego pliku i plików zależnych>
```

Podobnie jak w pliku `.prj`, pliki pakietów należy podawać jako pierwsze.

Wynik analizy prezentowany jest w terminalu, a pełny log dostępny jest w pliku `xrun.log`

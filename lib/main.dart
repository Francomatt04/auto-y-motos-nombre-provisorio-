import 'package:flutter/material.dart';

void main() => runApp(const AutoOMotoApp());

class AppColors {
  static const blue = Color(0xFF087CF5);
  static const navy = Color(0xFF18365E);
  static const ink = Color(0xFF1D2B3F);
  static const muted = Color(0xFF718096);
  static const canvas = Color(0xFFF3F6FB);
  static const line = Color(0xFFE4EAF2);
  static const orange = Color(0xFFFFA726);
  static const green = Color(0xFF20A875);
}

enum VehicleKind { car, moto }

class Vehicle {
  Vehicle({
    required this.id,
    required this.kind,
    required this.name,
    required this.model,
    required this.consumption,
    this.plate = '',
    this.kilometers = 0,
    this.maintenance = const [],
  });

  final String id;
  final VehicleKind kind;
  final String name;
  final String model;
  final double consumption;
  final String plate;
  final int kilometers;
  final List<String> maintenance;

  IconData get icon => kind == VehicleKind.car
      ? Icons.directions_car_filled_rounded
      : Icons.two_wheeler_rounded;
  String get kindLabel => kind == VehicleKind.car ? 'Auto' : 'Moto';
}

class TripRecord {
  TripRecord({
    required this.origin,
    required this.destination,
    required this.kilometers,
    required this.costCar,
    required this.costMoto,
    required this.mode,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  final String origin;
  final String destination;
  final double kilometers;
  final double costCar;
  final double costMoto;
  final String mode;
  final DateTime date;
  double get chosenCost => mode == 'Moto' ? costMoto : costCar;
}

class TripEstimate {
  const TripEstimate({
    required this.origin,
    required this.destination,
    required this.kilometers,
    required this.carCost,
    required this.motoCost,
    required this.tolls,
    required this.parking,
  });

  final String origin;
  final String destination;
  final double kilometers;
  final double carCost;
  final double motoCost;
  final double tolls;
  final double parking;
}

class DemoStore extends ChangeNotifier {
  final List<Vehicle> vehicles = [
    Vehicle(
      id: 'corolla',
      kind: VehicleKind.car,
      name: 'Toyota Corolla',
      model: 'XEi · 2018',
      consumption: 5.8,
      plate: 'AB 123 CD',
      kilometers: 84200,
      maintenance: ['Cambio de aceite', 'Filtro de aire', 'Revisión de frenos'],
    ),
    Vehicle(
      id: 'twister',
      kind: VehicleKind.moto,
      name: 'Honda Twister',
      model: 'CB 250 · 2022',
      consumption: 3.9,
      plate: 'A 456 XYZ',
      kilometers: 28100,
      maintenance: ['Cambio de aceite', 'Revisión de cadena'],
    ),
  ];

  final List<TripRecord> trips = [
    TripRecord(
      origin: 'Casa',
      destination: 'UCA',
      kilometers: 32,
      costCar: 1850,
      costMoto: 1240,
      mode: 'Auto',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TripRecord(
      origin: 'Casa',
      destination: 'Ciudad',
      kilometers: 14,
      costCar: 810,
      costMoto: 545,
      mode: 'Moto',
      date: DateTime.now().subtract(const Duration(days: 45)),
    ),
    TripRecord(
      origin: 'Casa',
      destination: 'Maipú',
      kilometers: 26,
      costCar: 1508,
      costMoto: 1014,
      mode: 'Auto',
      date: DateTime.now().subtract(const Duration(days: 220)),
    ),
  ];

  void addVehicle(Vehicle vehicle) {
    vehicles.add(vehicle);
    notifyListeners();
  }

  void addTrip(TripRecord trip) {
    trips.insert(0, trip);
    notifyListeners();
  }

  double get totalKilometers =>
      trips.fold<double>(0, (sum, trip) => sum + trip.kilometers);
  double get totalSpent =>
      trips.fold<double>(0, (sum, trip) => sum + trip.chosenCost);
  int get tripCount => trips.length;
}

class AutoOMotoApp extends StatefulWidget {
  const AutoOMotoApp({super.key});

  @override
  State<AutoOMotoApp> createState() => _AutoOMotoAppState();
}

class _AutoOMotoAppState extends State<AutoOMotoApp> {
  final DemoStore store = DemoStore();
  bool entered = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '¿Auto o moto?',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue),
        scaffoldBackgroundColor: AppColors.canvas,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.canvas,
          foregroundColor: AppColors.ink,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      builder: (context, child) => ResponsiveFrame(
        child: child ?? const SizedBox.shrink(),
      ),
      home: entered
          ? AppShell(
              store: store,
              onLogout: () => setState(() => entered = false),
            )
          : WelcomeScreen(
              onStart: () => setState(() => entered = true),
            ),
    );
  }
}

class ResponsiveFrame extends StatelessWidget {
  const ResponsiveFrame({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 600;
        return Container(
          color: wide ? const Color(0xFFE8EEF6) : Colors.white,
          alignment: Alignment.center,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460, maxHeight: 940),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(wide ? 30 : 0),
              boxShadow: wide
                  ? const [
                      BoxShadow(
                        color: Color(0x180D2340),
                        blurRadius: 36,
                        offset: Offset(0, 16),
                      ),
                    ]
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        );
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CustomPaint(painter: RoadScenePainter()),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF142943).withValues(alpha: .06),
                  const Color(0xFF142943).withValues(alpha: .78),
                ],
                stops: const [0.36, 0.62, 1],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 6),
                const Icon(Icons.route_rounded, color: Colors.white, size: 38),
                const SizedBox(height: 10),
                const Text(
                  '¿Auto o moto?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.7,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Calculá cuál es la mejor opción\npara tu viaje.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFE7F0FC), fontSize: 15),
                ),
                const Spacer(flex: 2),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 26),
                  child: PrimaryButton(label: 'Comenzar', onPressed: onStart),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RoadScenePainter extends CustomPainter {
  const RoadScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF78B7E8), Color(0xFFFFD6A1), Color(0xFFFFA96C)],
      ).createShader(rect);
    canvas.drawRect(rect, sky);

    final sunPaint = Paint()..color = const Color(0xFFFFE6A9);
    canvas.drawCircle(Offset(size.width * .76, size.height * .42), 42, sunPaint);

    final rearMountain = Path()
      ..moveTo(0, size.height * .66)
      ..lineTo(size.width * .22, size.height * .37)
      ..lineTo(size.width * .38, size.height * .58)
      ..lineTo(size.width * .60, size.height * .30)
      ..lineTo(size.width * .88, size.height * .62)
      ..lineTo(size.width, size.height * .48)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(rearMountain, Paint()..color = const Color(0xFF607F9A));

    final frontMountain = Path()
      ..moveTo(0, size.height * .72)
      ..lineTo(size.width * .22, size.height * .52)
      ..lineTo(size.width * .43, size.height * .73)
      ..lineTo(size.width * .69, size.height * .48)
      ..lineTo(size.width, size.height * .70)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(frontMountain, Paint()..color = const Color(0xFF344F65));

    final road = Path()
      ..moveTo(size.width * .43, size.height * .66)
      ..lineTo(size.width * .57, size.height * .66)
      ..lineTo(size.width * 1.08, size.height)
      ..lineTo(size.width * -.08, size.height)
      ..close();
    canvas.drawPath(road, Paint()..color = const Color(0xFF293746));

    final lane = Paint()
      ..color = const Color(0xFFEAF2F8)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final y = size.height * (.72 + i * .09);
      final halfWidth = (y - size.height * .66) * .36;
      canvas.drawLine(
        Offset(size.width * .5 - halfWidth, y),
        Offset(size.width * .5 + halfWidth, y),
        lane,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onContinue});
  final ValueChanged<String> onContinue;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool createAccount = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void continueDemo() {
    final name = email.text.trim().isEmpty
        ? 'Maxi'
        : email.text.trim().split('@').first;
    widget.onContinue(name.isEmpty ? 'Maxi' : name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: () => Navigator.pop(context))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(26, 8, 26, 30),
          children: [
            const BrandMark(),
            const SizedBox(height: 22),
            Text(
              createAccount ? 'Crear cuenta' : '¿Auto o Moto?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              createAccount
                  ? 'Completá tus datos para empezar a comparar.'
                  : 'Iniciá sesión para continuar',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 30),
            AppTextField(
              controller: email,
              label: 'Correo electrónico',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: password,
              label: 'Contraseña',
              icon: Icons.lock_outline_rounded,
              obscureText: true,
            ),
            if (createAccount) ...[
              const SizedBox(height: 14),
              const AppTextField(
                label: 'Confirmar contraseña',
                icon: Icons.lock_outline_rounded,
                obscureText: true,
              ),
            ],
            if (!createAccount)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const SimpleInfoScreen(
                        title: 'Recuperar contraseña',
                        message:
                            'Ingresá tu correo para recibir un enlace de recuperación. En esta demo el envío es simulado.',
                        icon: Icons.mark_email_unread_outlined,
                      ),
                    ),
                  ),
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: createAccount ? 'Registrarme' : 'Iniciar sesión',
              onPressed: continueDemo,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: continueDemo,
              icon: const Icon(Icons.g_mobiledata_rounded, size: 26),
              label: const Text('Continuar con Google'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: AppColors.ink,
                side: const BorderSide(color: AppColors.line),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () => setState(() => createAccount = !createAccount),
              child: Text(
                createAccount
                    ? 'Ya tengo una cuenta · Iniciar sesión'
                    : '¿No tenés cuenta? Registrate',
              ),
            ),
            TextButton(
              onPressed: continueDemo,
              child: const Text('Explorar demo sin cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          color: const Color(0xFFE7F2FF),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.route_rounded, color: AppColors.blue, size: 34),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.store, required this.onLogout});
  final DemoStore store;
  final VoidCallback onLogout;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selectedIndex = 0;
  String userName = 'Maxi';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AuthScreen(onContinue: (name) {
            setState(() => userName = name);
            Navigator.of(context).pop();
          }),
        ),
      );
    });
  }

  void openPlanner() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TripFormScreen(
          store: widget.store,
          onSave: (trip) => widget.store.addTrip(trip),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTab(
        store: widget.store,
        userName: userName,
        onPlan: openPlanner,
        onVehicles: () => setState(() => selectedIndex = 1),
        onHistory: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => HistoryTab(store: widget.store)),
        ),
      ),
      VehiclesTab(store: widget.store),
      const SizedBox.shrink(),
      StatsTab(store: widget.store),
      ProfileTab(
        userName: userName,
        store: widget.store,
        onVehicles: () => setState(() => selectedIndex = 1),
        onLogout: widget.onLogout,
      ),
    ];

    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) => Scaffold(
        body: IndexedStack(index: selectedIndex, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          height: 70,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFE8F2FF),
          onDestinationSelected: (index) {
            if (index == 2) {
              openPlanner();
            } else {
              setState(() => selectedIndex = index);
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.directions_car_outlined),
              selectedIcon: Icon(Icons.directions_car_filled_rounded),
              label: 'Vehículos',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline_rounded),
              selectedIcon: Icon(Icons.add_circle_rounded),
              label: 'Planificar',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Estadísticas',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.store,
    required this.userName,
    required this.onPlan,
    required this.onVehicles,
    required this.onHistory,
  });
  final DemoStore store;
  final String userName;
  final VoidCallback onPlan;
  final VoidCallback onVehicles;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, $userName 👋',
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '¿Qué viaje hacemos hoy?',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                backgroundColor: Color(0xFFDCEBFA),
                child: Icon(Icons.person_rounded, color: AppColors.blue),
              ),
            ],
          ),
          const SizedBox(height: 22),
          InkWell(
            onTap: onPlan,
            borderRadius: BorderRadius.circular(22),
            child: Ink(
              padding: const EdgeInsets.all(19),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F3FF),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.route_rounded, color: AppColors.blue),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calcular un nuevo viaje',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Compará auto y moto en segundos',
                          style: TextStyle(color: AppColors.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.blue),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Gastado en viajes',
                  value: money(store.totalSpent),
                  foot: 'en tus viajes guardados',
                  icon: Icons.payments_outlined,
                  tint: const Color(0xFFEAF2FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  label: 'Distancia',
                  value: '${store.totalKilometers.toStringAsFixed(0)} km',
                  foot: '${store.tripCount} viajes registrados',
                  icon: Icons.near_me_outlined,
                  tint: const Color(0xFFE8F7F0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionTitle(
            title: 'Tus vehículos',
            action: 'Ver todos',
            onAction: onVehicles,
          ),
          const SizedBox(height: 10),
          ...store.vehicles.take(2).map((vehicle) => VehicleCard(
                vehicle: vehicle,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => VehicleDetailScreen(vehicle: vehicle),
                  ),
                ),
              )),
          const SizedBox(height: 10),
          SectionTitle(title: 'Último viaje', action: 'Ver historial', onAction: onHistory),
          const SizedBox(height: 10),
          if (store.trips.isNotEmpty) TripCard(trip: store.trips.first),
        ],
      ),
    );
  }
}

class VehiclesTab extends StatelessWidget {
  const VehiclesTab({super.key, required this.store});
  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          const PageHeading(
            title: 'Mis vehículos',
            subtitle: 'Gestioná tus autos y motos',
          ),
          const SizedBox(height: 18),
          ...store.vehicles.map((vehicle) => VehicleCard(
                vehicle: vehicle,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => VehicleDetailScreen(vehicle: vehicle),
                  ),
                ),
              )),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => VehicleFormScreen(onSave: store.addVehicle),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar vehículo'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}

class StatsTab extends StatefulWidget {
  const StatsTab({super.key, required this.store});
  final DemoStore store;

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  String period = 'Este mes';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final cutoff = period == 'Este mes'
        ? DateTime(now.year, now.month, 1)
        : period == '3 meses'
            ? now.subtract(const Duration(days: 90))
            : DateTime(now.year, 1, 1);
    final visibleTrips = widget.store.trips
        .where((trip) => !trip.date.isBefore(cutoff))
        .toList();
    final total = visibleTrips.fold<double>(
      0,
      (sum, trip) => sum + trip.chosenCost,
    );
    final kilometers = visibleTrips.fold<double>(
      0,
      (sum, trip) => sum + trip.kilometers,
    );
    final autoTotal = visibleTrips
        .where((trip) => trip.mode == 'Auto')
        .fold<double>(0, (sum, trip) => sum + trip.chosenCost);
    final motoTotal = visibleTrips
        .where((trip) => trip.mode == 'Moto')
        .fold<double>(0, (sum, trip) => sum + trip.chosenCost);
    final chartMax = autoTotal > motoTotal ? autoTotal : motoTotal;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          const PageHeading(title: 'Estadísticas', subtitle: 'Tus viajes, con datos claros'),
          const SizedBox(height: 18),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Este mes', label: Text('Este mes')),
              ButtonSegment(value: '3 meses', label: Text('3 meses')),
              ButtonSegment(value: 'Este año', label: Text('Este año')),
            ],
            selected: {period},
            onSelectionChanged: (value) => setState(() => period = value.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Gasto total',
                  value: money(total),
                  foot: 'según tus viajes guardados',
                  icon: Icons.account_balance_wallet_outlined,
                  tint: const Color(0xFFEAF2FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  label: 'Distancia',
                  value: '${kilometers.toStringAsFixed(0)} km',
                  foot: 'recorridos en total',
                  icon: Icons.route_rounded,
                  tint: const Color(0xFFE8F7F0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gasto por vehículo', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                const Text('Comparación estimada', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 20),
                ChartBar(label: 'Auto', amount: autoTotal, maxAmount: chartMax, color: AppColors.blue),
                const SizedBox(height: 16),
                ChartBar(label: 'Moto', amount: motoTotal, maxAmount: chartMax, color: AppColors.orange),
                const SizedBox(height: 8),
                const Text('Los valores son ilustrativos para esta demo.', style: TextStyle(color: AppColors.muted, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Row(
              children: [
                const Icon(Icons.insights_rounded, color: AppColors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'En este período registraste ${visibleTrips.length} viajes y ${kilometers.toStringAsFixed(0)} km. Seguí cargando viajes para comparar tus gastos.',
                    style: const TextStyle(color: AppColors.ink, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key, required this.store});
  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de viajes')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const PageHeading(title: 'Tus recorridos recientes', subtitle: 'El detalle de cada viaje guardado'),
            const SizedBox(height: 16),
            ...store.trips.map((trip) => TripCard(trip: trip)),
            if (store.trips.isEmpty)
              const EmptyState(
                icon: Icons.route_outlined,
                title: 'Todavía no guardaste viajes',
                message: 'Cuando calcules uno, va a aparecer acá.',
              ),
          ],
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.userName,
    required this.store,
    required this.onVehicles,
    required this.onLogout,
  });
  final String userName;
  final DemoStore store;
  final VoidCallback onVehicles;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          const PageHeading(title: 'Mi perfil', subtitle: 'Tu cuenta y preferencias'),
          const SizedBox(height: 18),
          AppCard(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFFE4F0FF),
                  child: Icon(Icons.person_rounded, color: AppColors.blue, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 3),
                      const Text('Modo demostración', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.edit_outlined, color: AppColors.blue),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text('Cuenta', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy)),
          const SizedBox(height: 8),
          MenuTile(
            icon: Icons.directions_car_outlined,
            title: 'Mis vehículos',
            onTap: onVehicles,
          ),
          MenuTile(
            icon: Icons.history_rounded,
            title: 'Historial de viajes',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => HistoryTab(store: store)),
            ),
          ),
          MenuTile(
            icon: Icons.tune_rounded,
            title: 'Configuración',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const SimpleInfoScreen(
                  title: 'Configuración',
                  message: 'Preferencias de viaje, moneda y notificaciones.',
                  icon: Icons.tune_rounded,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Ayuda y soporte', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy)),
          const SizedBox(height: 8),
          MenuTile(
            icon: Icons.help_outline_rounded,
            title: 'Centro de ayuda',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const SimpleInfoScreen(
                  title: 'Ayuda y soporte',
                  message: 'Encontrá respuestas sobre viajes, costos y mantenimiento. Esta sección funciona como contenido de demostración.',
                  icon: Icons.support_agent_rounded,
                ),
              ),
            ),
          ),
          MenuTile(
            icon: Icons.description_outlined,
            title: 'Términos y condiciones',
            onTap: () => _openInfo(context, 'Términos y condiciones'),
          ),
          MenuTile(
            icon: Icons.shield_outlined,
            title: 'Política de privacidad',
            onTap: () => _openInfo(context, 'Política de privacidad'),
          ),
          MenuTile(
            icon: Icons.star_border_rounded,
            title: 'Calificar la app',
            onTap: () => _openInfo(context, 'Calificar la app'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onLogout,
            child: const Text('Cerrar sesión'),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text('¿Auto o moto? · Demo académica', style: TextStyle(color: AppColors.muted, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  void _openInfo(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SimpleInfoScreen(
          title: title,
          message: 'Contenido de demostración. El equipo puede completar esta información antes de publicar la versión final.',
          icon: title.contains('privacidad') ? Icons.shield_outlined : Icons.description_outlined,
        ),
      ),
    );
  }
}

class TripFormScreen extends StatefulWidget {
  const TripFormScreen({super.key, required this.store, required this.onSave});
  final DemoStore store;
  final ValueChanged<TripRecord> onSave;

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final formKey = GlobalKey<FormState>();
  final origin = TextEditingController(text: 'Casa');
  final destination = TextEditingController(text: 'Universidad');
  final distance = TextEditingController(text: '32');
  final fuelPrice = TextEditingController(text: '1000');
  final tolls = TextEditingController(text: '0');
  final parking = TextEditingController(text: '0');

  @override
  void dispose() {
    origin.dispose();
    destination.dispose();
    distance.dispose();
    fuelPrice.dispose();
    tolls.dispose();
    parking.dispose();
    super.dispose();
  }

  Vehicle? get car => widget.store.vehicles.cast<Vehicle?>().firstWhere(
        (vehicle) => vehicle?.kind == VehicleKind.car,
        orElse: () => null,
      );
  Vehicle? get moto => widget.store.vehicles.cast<Vehicle?>().firstWhere(
        (vehicle) => vehicle?.kind == VehicleKind.moto,
        orElse: () => null,
      );

  void calculate() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final km = double.parse(distance.text.replaceAll(',', '.'));
    final price = double.parse(fuelPrice.text.replaceAll(',', '.'));
    final extra = _number(tolls.text) + _number(parking.text);
    final carConsumption = car?.consumption ?? 5.8;
    final motoConsumption = moto?.consumption ?? 3.9;
    final quote = TripEstimate(
      origin: origin.text.trim(),
      destination: destination.text.trim(),
      kilometers: km,
      carCost: (km * carConsumption / 100 * price) + extra,
      motoCost: (km * motoConsumption / 100 * price) + extra,
      tolls: _number(tolls.text),
      parking: _number(parking.text),
    );
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => TripResultScreen(
          estimate: quote,
          onSave: (mode) {
            widget.onSave(TripRecord(
              origin: quote.origin,
              destination: quote.destination,
              kilometers: quote.kilometers,
              costCar: quote.carCost,
              costMoto: quote.motoCost,
              mode: mode,
            ));
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo viaje')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            const Text('¿A dónde vas?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.navy)),
            const SizedBox(height: 6),
            const Text('Completá los datos para comparar costos.', style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 20),
            AppTextField(controller: origin, label: 'Origen', icon: Icons.trip_origin_rounded),
            const SizedBox(height: 12),
            AppTextField(controller: destination, label: 'Destino', icon: Icons.location_on_outlined),
            const SizedBox(height: 12),
            AppTextField(
              controller: distance,
              label: 'Distancia del viaje (km)',
              icon: Icons.route_rounded,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) => _positiveNumber(value, 'Ingresá una distancia válida'),
            ),
            const SizedBox(height: 18),
            const Text('Costos adicionales', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy)),
            const SizedBox(height: 10),
            AppTextField(
              controller: fuelPrice,
              label: 'Precio del combustible por litro',
              icon: Icons.local_gas_station_outlined,
              keyboardType: TextInputType.number,
              validator: (value) => _positiveNumber(value, 'Ingresá un precio válido'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: AppTextField(controller: tolls, label: 'Peajes', icon: Icons.toll_outlined, keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: AppTextField(controller: parking, label: 'Estacionamiento', icon: Icons.local_parking_rounded, keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'La estimación usa el consumo cargado en tus vehículos. Si todavía no agregaste uno, usa valores de referencia.',
                      style: TextStyle(color: AppColors.muted, height: 1.35, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(label: 'Calcular costos', onPressed: calculate),
          ],
        ),
      ),
    );
  }
}

class TripResultScreen extends StatelessWidget {
  const TripResultScreen({super.key, required this.estimate, required this.onSave});
  final TripEstimate estimate;
  final ValueChanged<String> onSave;

  @override
  Widget build(BuildContext context) {
    final cheaper = estimate.carCost <= estimate.motoCost ? 'Auto' : 'Moto';
    final savings = (estimate.carCost - estimate.motoCost).abs();
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado del viaje')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 26),
        children: [
          const Text('Compará antes de salir', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.navy)),
          const SizedBox(height: 5),
          Text('${estimate.origin} → ${estimate.destination} · ${estimate.kilometers.toStringAsFixed(0)} km', style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: CostCard(title: 'AUTO', amount: estimate.carCost, color: AppColors.blue, icon: Icons.directions_car_filled_rounded)),
              const SizedBox(width: 12),
              Expanded(child: CostCard(title: 'MOTO', amount: estimate.motoCost, color: AppColors.orange, icon: Icons.two_wheeler_rounded)),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$cheaper es la opción más económica. Ahorrás ${money(savings)} en este recorrido.',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Desglose estimado', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                DetailRow(label: 'Combustible', value: 'Incluido en cada opción'),
                DetailRow(label: 'Peajes', value: money(estimate.tolls)),
                DetailRow(label: 'Estacionamiento', value: money(estimate.parking)),
                const Divider(height: 20),
                DetailRow(label: 'Distancia', value: '${estimate.kilometers.toStringAsFixed(1)} km'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(label: 'Guardar y usar $cheaper', onPressed: () => onSave(cheaper)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => onSave(cheaper == 'Auto' ? 'Moto' : 'Auto'),
            child: Text('Guardar y usar ${cheaper == 'Auto' ? 'Moto' : 'Auto'}'),
          ),
          const Center(
            child: Text('Estimación de demostración; el costo real puede variar.', style: TextStyle(color: AppColors.muted, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class VehicleFormScreen extends StatefulWidget {
  const VehicleFormScreen({super.key, required this.onSave});
  final ValueChanged<Vehicle> onSave;

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final model = TextEditingController();
  final consumption = TextEditingController(text: '6.0');
  final plate = TextEditingController();
  VehicleKind kind = VehicleKind.car;

  @override
  void dispose() {
    name.dispose();
    model.dispose();
    consumption.dispose();
    plate.dispose();
    super.dispose();
  }

  void save() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    widget.onSave(Vehicle(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      kind: kind,
      name: name.text.trim(),
      model: model.text.trim().isEmpty ? 'Modelo sin especificar' : model.text.trim(),
      consumption: double.parse(consumption.text.replaceAll(',', '.')),
      plate: plate.text.trim(),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar vehículo')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Tipo de vehículo', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy)),
            const SizedBox(height: 10),
            SegmentedButton<VehicleKind>(
              segments: const [
                ButtonSegment(value: VehicleKind.car, icon: Icon(Icons.directions_car), label: Text('Auto')),
                ButtonSegment(value: VehicleKind.moto, icon: Icon(Icons.two_wheeler), label: Text('Moto')),
              ],
              selected: {kind},
              onSelectionChanged: (value) => setState(() {
                kind = value.first;
                consumption.text = kind == VehicleKind.car ? '6.0' : '3.9';
              }),
            ),
            const SizedBox(height: 18),
            AppTextField(controller: name, label: 'Marca y modelo', icon: Icons.directions_car_outlined, validator: (v) => (v == null || v.trim().isEmpty) ? 'Completá este campo' : null),
            const SizedBox(height: 12),
            AppTextField(controller: model, label: 'Versión y año (opcional)', icon: Icons.info_outline_rounded),
            const SizedBox(height: 12),
            AppTextField(controller: plate, label: 'Patente (opcional)', icon: Icons.badge_outlined),
            const SizedBox(height: 12),
            AppTextField(
              controller: consumption,
              label: 'Consumo promedio (litros cada 100 km)',
              icon: Icons.local_gas_station_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => _positiveNumber(v, 'Ingresá un consumo válido'),
            ),
            const SizedBox(height: 22),
            PrimaryButton(label: 'Guardar vehículo', onPressed: save),
          ],
        ),
      ),
    );
  }
}

class VehicleDetailScreen extends StatelessWidget {
  const VehicleDetailScreen({super.key, required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(vehicle.kindLabel)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 26),
        children: [
          AppCard(
            color: vehicle.kind == VehicleKind.car ? const Color(0xFFDCE9FF) : const Color(0xFFFFE8C5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(vehicle.icon, color: vehicle.kind == VehicleKind.car ? AppColors.blue : AppColors.orange, size: 38),
                const SizedBox(height: 10),
                Text(vehicle.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.navy)),
                Text(vehicle.model, style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 14),
                Text('${money(vehicle.consumption * 1000)}/100 km', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const Text('estimación con combustible a \$1.000/litro', style: TextStyle(color: AppColors.muted, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              children: [
                DetailRow(label: 'Patente', value: vehicle.plate.isEmpty ? 'Sin cargar' : vehicle.plate),
                DetailRow(label: 'Consumo', value: '${vehicle.consumption.toStringAsFixed(1)} L/100 km'),
                DetailRow(label: 'Kilometraje', value: '${vehicle.kilometers} km'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionTitle(
            title: 'Mantenimiento',
            action: 'Ver detalle',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => MaintenanceScreen(vehicle: vehicle)),
            ),
          ),
          const SizedBox(height: 8),
          ...vehicle.maintenance.map((item) => MenuTile(
                icon: Icons.build_circle_outlined,
                title: item,
                subtitle: 'Revisar próximamente',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => MaintenanceScreen(vehicle: vehicle)),
                ),
              )),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Registrar mantenimiento',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => MaintenanceScreen(vehicle: vehicle)),
            ),
          ),
        ],
      ),
    );
  }
}

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key, required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mantenimiento')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(vehicle.name, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy, fontSize: 20)),
          const SizedBox(height: 5),
          Text('${vehicle.kilometers} km registrados', style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 18),
          AppCard(
            color: const Color(0xFFEAF2FF),
            child: const Row(
              children: [
                Icon(Icons.notifications_active_outlined, color: AppColors.blue),
                SizedBox(width: 12),
                Expanded(child: Text('Llevá el mantenimiento al día para cuidar tu vehículo.', style: TextStyle(height: 1.35))),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...vehicle.maintenance.asMap().entries.map((entry) => AppCard(
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const CircleAvatar(backgroundColor: Color(0xFFE8F7F0), child: Icon(Icons.check_rounded, color: AppColors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w700))),
                    Text('${(entry.key + 1) * 5000} km', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              )),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mantenimiento registrado en esta demo.')),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar tarea'),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          ),
        ],
      ),
    );
  }
}

class SimpleInfoScreen extends StatelessWidget {
  const SimpleInfoScreen({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
  });
  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            BrandMark(),
            const SizedBox(height: 20),
            Icon(icon, color: AppColors.blue, size: 42),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 21, color: AppColors.navy)),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, height: 1.5)),
            const Spacer(),
            PrimaryButton(label: 'Volver', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
  });
  final TextEditingController? controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: AppColors.muted, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.color = Colors.white, this.margin});
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color == Colors.white ? AppColors.line : color),
      ),
      child: child,
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.foot,
    required this.icon,
    required this.tint,
  });
  final String label;
  final String value;
  final String foot;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 17, backgroundColor: tint, child: Icon(icon, color: AppColors.blue, size: 18)),
          const SizedBox(height: 11),
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
          const SizedBox(height: 4),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(value, style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800, fontSize: 20)),
          ),
          const SizedBox(height: 4),
          Text(foot, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
        ],
      ),
    );
  }
}

class PageHeading extends StatelessWidget {
  const PageHeading({super.key, required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppColors.navy, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: const TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.w800))),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!, style: const TextStyle(fontSize: 12))),
      ],
    );
  }
}

class VehicleCard extends StatelessWidget {
  const VehicleCard({super.key, required this.vehicle, required this.onTap});
  final Vehicle vehicle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = vehicle.kind == VehicleKind.car ? const Color(0xFFDCE9FF) : const Color(0xFFFFE9C9);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AppCard(
          color: color,
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withValues(alpha: .8),
                child: Icon(vehicle.icon, color: vehicle.kind == VehicleKind.car ? AppColors.blue : AppColors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vehicle.name, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy)),
                    const SizedBox(height: 3),
                    Text('${vehicle.model} · ${vehicle.kindLabel}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                    const SizedBox(height: 6),
                    Text('${vehicle.consumption.toStringAsFixed(1)} L/100 km', style: const TextStyle(color: AppColors.ink, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  const TripCard({super.key, required this.trip});
  final TripRecord trip;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFEAF2FF),
            child: Icon(trip.mode == 'Moto' ? Icons.two_wheeler_rounded : Icons.directions_car_filled_rounded, color: AppColors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${trip.origin} → ${trip.destination}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)),
                const SizedBox(height: 4),
                Text('${trip.kilometers.toStringAsFixed(0)} km · ${trip.date.day}/${trip.date.month}/${trip.date.year}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              ],
            ),
          ),
          Text(money(trip.chosenCost), style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class CostCard extends StatelessWidget {
  const CostCard({super.key, required this.title, required this.amount, required this.color, required this.icon});
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: color.withValues(alpha: .09),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w800, letterSpacing: .7)),
          const SizedBox(height: 5),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(money(amount), style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800, fontSize: 22)),
          ),
          const Text('costo aproximado', style: TextStyle(color: AppColors.muted, fontSize: 10)),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.muted))),
          Text(value, style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class ChartBar extends StatelessWidget {
  const ChartBar({super.key, required this.label, required this.amount, required this.maxAmount, required this.color});
  final String label;
  final double amount;
  final double maxAmount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fraction = maxAmount <= 0 ? .05 : (amount / maxAmount).clamp(.05, 1.0).toDouble();
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 42, child: Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12))),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(value: fraction, minHeight: 12, color: color, backgroundColor: const Color(0xFFF0F3F8)),
              ),
            ),
            const SizedBox(width: 10),
            Text(money(amount), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class MenuTile extends StatelessWidget {
  const MenuTile({super.key, required this.icon, required this.title, this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.line),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: subtitle == null ? null : Text(subtitle!, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        onTap: onTap,
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 52),
      child: Column(
        children: [
          Icon(icon, size: 44, color: AppColors.blue),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy)),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}

double _number(String value) => double.tryParse(value.trim().replaceAll(',', '.')) ?? 0;

String? _positiveNumber(String? value, String message) {
  final parsed = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
  if (parsed == null || parsed <= 0) return message;
  return null;
}

String money(num value) {
  final rounded = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < rounded.length; i++) {
    if (i > 0 && (rounded.length - i) % 3 == 0) buffer.write('.');
    buffer.write(rounded[i]);
  }
  return '\$$buffer';
}

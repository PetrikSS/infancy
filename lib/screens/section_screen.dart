import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SectionScreen extends StatefulWidget {
  const SectionScreen({super.key});

  @override
  State<SectionScreen> createState() => _SectionScreenState();
}

class _SectionScreenState extends State<SectionScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Активные фильтры
  Map<String, List<String>> _activeFilters = {
    'location': [],
    'category': [],
    'age': [],
    'price': [],
  };

  // Данные для фильтров
  final Map<String, List<String>> _filterOptions = {
    'location': [
      'Центральный округ',
      'Кировский округ',
      'Ленинский округ',
      'Октябрьский округ',
      'Советский округ',
    ],
    'category': [
      'Программирование',
      'Робототехника',
      'Дизайн',
      '3D-моделирование',
      'Проектная деятельность',
      'Наука',
      'Искусство',
      'Языки',
      'Спорт',
      'Творчество'
    ],
    'age': [
      '3-6 лет',
      '7-10 лет',
      '11-14 лет',
      '15-18 лет',
      'Взрослые',
      'Старшее поколение',
      'Вся семья'
    ],
    'price': ['Бесплатно', 'До 5000₽', '5000-10000₽', 'От 10000₽'],
  };

  // Пример данных мероприятий
  final List<SectionItem> _sections = [
    SectionItem(
      id: '1',
      title: 'Проектная деятельность',
      address: 'ул. Богдана Хмельницкого, 224',
      imageUrl: 'assets/images/magistrcoda/magistrcoda1.jpeg',
      organization: 'ООО "Магистр Кода"',
      description: 'Практический курс, на котором дети превратят свою идею в работающий прототип мобильного приложения. Узнают, как работают цифровые продукты, и создадут собственный проект с нуля.',
      website: 'https://magistr-code.ru/',
      isFavorite: false,
      category: 'Программирование',
      ageGroup: '15-18 лет',
      price: '5000-10000₽',
      location: 'Кировский округ',
    ),
    SectionItem(
      id: '2',
      title: 'Графический дизайн, 3D-моделирование',
      address: 'ул. Комарова, 2/2',
      imageUrl: 'assets/images/magistrcoda/magistrcoda5.jpg',
      organization: 'ООО "Магистр Кода"',
      description: 'Обучение основам графического дизайна и композиции. Работа с различными материалами и техниками.',
      website: 'https://magistr-code.ru/',
      isFavorite: false,
      category: 'Дизайн',
      ageGroup: '11-14 лет',
      price: '5000-10000₽',
      location: 'Центральный округ',
    ),
    SectionItem(
      id: '3',
      title: 'Программирование Python',
      address: 'ул. Красный Путь, 24к1',
      imageUrl: 'assets/images/magistrcoda/magistrcoda2.webp',
      organization: 'ООО "Магистр Кода"',
      description: 'Изучение основ программирования через создание игр и приложений. Scratch, Python, основы веб-разработки.',
      website: 'https://magistr-code.ru/',
      isFavorite: false,
      category: 'Программирование',
      ageGroup: '11-14 лет',
      price: '5000-10000₽',
      location: 'Центральный округ',
    ),
    SectionItem(
      id: '4',
      title: 'Робототехника',
      address: 'ул. Богдана Хмельницкого, 224',
      imageUrl: 'assets/images/magistrcoda/magistrcoda3.jpg',
      organization: 'ООО "Магистр Кода"',
      description: 'Интерактивные занятия для детей 6-12 лет для развития критического и аналитического мышления. Создаем роботов своими руками и пишем код для них!',
      website: 'https://magistr-code.ru/',
      isFavorite: false,
      category: 'Робототехника',
      ageGroup: '7-10 лет',
      price: '5000-10000₽',
      location: 'Кировский округ',
    ),
  ];

  List<SectionItem> get _filteredSections {
    var filtered = _sections;

    // Фильтрация по поиску
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((section) =>
      section.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          section.organization.toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }

    // Фильтрация по местоположению
    if (_activeFilters['location']!.isNotEmpty) {
      filtered = filtered.where((section) =>
          _activeFilters['location']!.contains(section.location)
      ).toList();
    }

    // Фильтрация по категории
    if (_activeFilters['category']!.isNotEmpty) {
      filtered = filtered.where((section) =>
          _activeFilters['category']!.contains(section.category)
      ).toList();
    }

    // Фильтрация по возрасту
    if (_activeFilters['age']!.isNotEmpty) {
      filtered = filtered.where((section) =>
          _activeFilters['age']!.contains(section.ageGroup)
      ).toList();
    }

    // Фильтрация по цене
    if (_activeFilters['price']!.isNotEmpty) {
      filtered = filtered.where((section) =>
          _activeFilters['price']!.contains(section.price)
      ).toList();
    }

    return filtered;
  }

  int get _activeFiltersCount {
    return _activeFilters.values.fold(0, (sum, list) => sum + list.length);
  }

  void _toggleFavorite(String id) {
    setState(() {
      final index = _sections.indexWhere((section) => section.id == id);
      if (index != -1) {
        _sections[index] = _sections[index].copyWith(
            isFavorite: !_sections[index].isFavorite
        );
      }
    });
  }

  void _showSectionDetails(SectionItem section) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SectionDetailsModal(
        section: section,
        onToggleFavorite: _toggleFavorite,
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterModal(
        activeFilters: _activeFilters,
        filterOptions: _filterOptions,
        onFiltersChanged: (newFilters) {
          setState(() {
            _activeFilters = newFilters.cast<String, List<String>>();
          });
        },
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilters = {
        'location': [],
        'category': [],
        'age': [],
        'price': [],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Поисковая строка и кнопка фильтра
            _buildSearchBar(),
            // Список мероприятий
            _buildSectionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16, left: 24,right: 24),
      child: Column(
        children: [
          // Строка поиска
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Поиск секций и мероприятий...',
                hintStyle: const TextStyle(color: Colors.black38),
                prefixIcon: const Icon(LineAwesomeIcons.search_solid, color: Colors.black54),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(LineAwesomeIcons.times_solid, color: Colors.black54),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Строка с фильтрами
          Row(
            children: [
              // Кнопка фильтра
              Expanded(
                child: GestureDetector(
                  onTap: _showFilterModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(LineAwesomeIcons.filter_solid, size: 16, color: Colors.black54),
                            const SizedBox(width: 8),
                            Text(
                              _activeFiltersCount > 0
                                  ? 'Фильтры ($_activeFiltersCount)'
                                  : 'Все фильтры',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        if (_activeFiltersCount > 0)
                          GestureDetector(
                            onTap: _clearAllFilters,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black12,
                              ),
                              child: const Icon(
                                LineAwesomeIcons.times_solid,
                                size: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsList() {
    return Expanded(
      child: _filteredSections.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredSections.length,
        itemBuilder: (context, index) {
          final section = _filteredSections[index];
          return _SectionCard(
            section: section,
            onTap: () => _showSectionDetails(section),
            onFavoriteTap: () => _toggleFavorite(section.id),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFC0CB), Color(0xFFFFD4A3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              LineAwesomeIcons.search_solid,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Ничего не найдено',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4A4A),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Попробуйте изменить поисковый запрос\nили выбрать другие фильтры',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF888888),
                height: 1.5,
              ),
            ),
          ),
          if (_activeFiltersCount > 0) ...[
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFC0CB), Color(0xFFFFD4A3)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _clearAllFilters,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      'Сбросить все фильтры',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SectionItem {
  final String id;
  final String title;
  final String address;
  final String imageUrl;
  final String organization;
  final String description;
  final String website;
  final String category;
  final String ageGroup;
  final String price;
  final String location;
  bool isFavorite;

  SectionItem({
    required this.id,
    required this.title,
    required this.address,
    required this.imageUrl,
    required this.organization,
    required this.description,
    required this.website,
    required this.isFavorite,
    required this.category,
    required this.ageGroup,
    required this.price,
    required this.location,
  });

  SectionItem copyWith({
    bool? isFavorite,
  }) {
    return SectionItem(
      id: id,
      title: title,
      address: address,
      imageUrl: imageUrl,
      organization: organization,
      description: description,
      website: website,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category,
      ageGroup: ageGroup,
      price: price,
      location: location,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final SectionItem section;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const _SectionCard({
    required this.section,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16, left: 12,right: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Изображение
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: section.imageUrl.startsWith('http')
                  ? Image.network(
                section.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              )
                  : Image.asset(
                section.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              ),
            ),
            // Контент
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          section.address,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Кнопка "нравится"
                  IconButton(
                    onPressed: onFavoriteTap,
                    icon: Icon(
                      section.isFavorite ? LineAwesomeIcons.heart_solid : LineAwesomeIcons.heart,
                      color: section.isFavorite ? const Color(0xFFFF8989) : Colors.black54,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 160,
      color: const Color(0xFFFFC0CB),
      child: const Icon(
        LineAwesomeIcons.image,
        size: 50,
        color: Colors.white,
      ),
    );
  }
}

class _SectionDetailsModal extends StatelessWidget {
  final SectionItem section;
  final Function(String) onToggleFavorite;

  const _SectionDetailsModal({
    required this.section,
    required this.onToggleFavorite,
  });

  void _openWebsite(BuildContext context) async {
    final Uri url = Uri.parse(section.website);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось открыть ссылку: ${section.website}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Заголовок с кнопкой закрытия
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LineAwesomeIcons.times_solid, color: Colors.black54),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => onToggleFavorite(section.id),
                  icon: Icon(
                    section.isFavorite ? LineAwesomeIcons.heart_solid : LineAwesomeIcons.heart,
                    color: section.isFavorite ? const Color(0xFFFF8989) : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          // Изображение
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: section.imageUrl.startsWith('http')
                ? Image.network(
              section.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: const Color(0xFFFFC0CB),
                  child: const Icon(
                    LineAwesomeIcons.image,
                    size: 60,
                    color: Colors.white,
                  ),
                );
              },
            )
                : Image.asset(
              section.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: const Color(0xFFFFC0CB),
                  child: const Icon(
                    LineAwesomeIcons.image,
                    size: 60,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
          // Контент
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(LineAwesomeIcons.building, size: 16, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text(
                      section.organization,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(LineAwesomeIcons.map_marker_solid, size: 16, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text(
                      section.address,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFA9B8).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        section.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFF8989),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD4A3).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        section.ageGroup,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFF9950),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC8E6C9).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        section.price,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Описание:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  section.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Кнопка записи
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFC0CB), Color(0xFFFFD4A3)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _openWebsite(context),
                      borderRadius: BorderRadius.circular(28),
                      child: const Center(
                        child: Text(
                          'Записаться на сайте',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
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

class _FilterModal extends StatefulWidget {
  final Map<String, dynamic> activeFilters;
  final Map<String, List<String>> filterOptions;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const _FilterModal({
    required this.activeFilters,
    required this.filterOptions,
    required this.onFiltersChanged,
  });

  @override
  State<_FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<_FilterModal> {
  late Map<String, dynamic> _tempFilters;

  @override
  void initState() {
    super.initState();
    _tempFilters = Map.from(widget.activeFilters);
  }

  void _toggleFilter(String category, String value) {
    setState(() {
      if (_tempFilters[category]!.contains(value)) {
        _tempFilters[category]!.remove(value);
      } else {
        _tempFilters[category]!.add(value);
      }
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(_tempFilters);
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _tempFilters = {
        'location': [],
        'category': [],
        'age': [],
        'price': [],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Заголовок
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LineAwesomeIcons.times_solid, color: Colors.black54),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Фильтры',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text(
                    'Очистить',
                    style: TextStyle(
                      color: Color(0xFF272727),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterSection('Округ', 'location', LineAwesomeIcons.map_marker_solid),
                _buildFilterSection('Категория', 'category', LineAwesomeIcons.tag_solid),
                _buildFilterSection('Возраст', 'age', LineAwesomeIcons.user_solid),
                _buildFilterSection('Цена', 'price', LineAwesomeIcons.money_bill_solid),
              ],
            ),
          ),
          // Кнопка применения
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFC0CB), Color(0xFFFFD4A3)],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _applyFilters,
                  borderRadius: BorderRadius.circular(28),
                  child: const Center(
                    child: Text(
                      'Применить фильтры',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, String category, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.black54),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.filterOptions[category]!.map((option) {
            final isSelected = _tempFilters[category]!.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) => _toggleFilter(category, option),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFFFC0CB),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? const Color(0xFFFFC0CB) : Colors.black26,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
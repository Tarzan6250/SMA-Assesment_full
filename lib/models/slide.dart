class Slide {
  final String title;
  final String imagePath;

  const Slide({
    required this.title,
    required this.imagePath,
  });
}

final List<Slide> slides = [
  const Slide(
    title: 'Experience an all-in-one solution\nfor managing school operations\neffortlessly.',
    imagePath: 'assets/images/slide1.jpg',
  ),
  const Slide(
    title: 'Streamline your administrative\ntasks with our comprehensive\nmanagement system.',
    imagePath: 'assets/images/slide2.jpg',
  ),
  const Slide(
    title: 'Empower your staff with\nefficient tools for better\nschool management.',
    imagePath: 'assets/images/slide3.jpg',
  ),
];

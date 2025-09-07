# vytalLink Frontend

A modern and responsive landing page for vytalLink - the OAuth 2.0 server for health data integration.

## Features

- **Modern Design**: Clean and professional interface with gradients and smooth animations
- **Fully Responsive**: Perfectly adapts to mobile devices, tablets, and desktop
- **Real-time Data**: Health metrics simulation that updates dynamically
- **Smooth Animations**: Scroll effects and CSS transitions for better user experience
- **Interactive Dashboard**: Health metrics visualization with FontAwesome icons

## Structure

```
frontend/
├── index.html          # Main page
├── styles.css          # CSS styles with CSS variables and responsive design
├── script.js          # JavaScript for interactivity and animations
└── README.md          # This file
```

## Key Features

### 🎨 Design
- Professional color scheme with gradients
- Inter typography for better readability
- FontAwesome icons for visual elements
- Smooth hover effects and transitions

### 📱 Responsive
- CSS Grid for adaptive layouts
- Hamburger menu for mobile
- Optimization for different screen sizes

### ⚡ Interactivity
- Smooth scrolling between sections
- Scroll animations (Intersection Observer)
- Real-time health data simulation
- Functional mobile menu

### 🏥 Health Dashboard
- Simulated metrics: Heart rate, steps, sleep, calories
- Real-time status indicator
- Updates every 3 seconds

## Landing Sections

1. **Hero Section**: Main introduction with call-to-action
2. **Features**: Key vytalLink features
3. **API Overview**: API information with code example
4. **Getting Started**: Quick 3-step guide
5. **Footer**: Links and additional information

## Technologies Used

- **HTML5**: Semantic structure
- **CSS3**: 
  - Custom CSS variables
  - Grid and Flexbox
  - Animations and transitions
  - Media queries for responsiveness
- **Vanilla JavaScript**:
  - Intersection Observer API
  - Event listeners
  - DOM manipulation
  - Real-time updates

## How to Use

The landing page is automatically served when you run the vytalLink server:

1. **With Docker**:
   ```bash
   docker-compose up -d
   ```

2. **Local development**:
   ```bash
   cd backend
   python main.py
   ```

3. **Access**: Go to `http://localhost:8000` to see the landing page

## Customization

### Colors
Modify CSS variables in `styles.css`:
```css
:root {
    --primary-color: #6366f1;
    --accent-color: #10b981;
    /* ... more variables */
}
```

### Content
Edit text in `index.html` to customize:
- Titles and descriptions
- Features
- Contact information

### Functionality
Modify `script.js` to:
- Change update intervals
- Add new animations
- Customize behaviors

## Optimizations

- **Performance**: Optimized CSS and JS for fast loading
- **SEO**: Meta tags and semantic structure
- **Accessibility**: Keyboard navigation and proper contrast
- **Cross-browser**: Compatible with modern browsers

## Future Improvements

- [ ] Dark/light theme
- [ ] Internationalization (i18n)
- [ ] More code examples
- [ ] Live API documentation integration
- [ ] Analytics and usage metrics

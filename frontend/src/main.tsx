import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { Provider } from 'react-redux'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import { ThemeProvider } from '@mui/material/styles'
import CssBaseline from '@mui/material/CssBaseline'
import { ToastContainer } from 'react-toastify'

// Import styles
import 'react-toastify/dist/ReactToastify.css'

// Import store and theme (to be created)
// import { store } from '@/store'
// import { theme } from '@/theme'
// import App from '@/App'

// Temporary App component until the actual App is created
const TempApp = () => (
  <div style={{ 
    display: 'flex', 
    justifyContent: 'center', 
    alignItems: 'center', 
    minHeight: '100vh',
    flexDirection: 'column',
    gap: '20px',
    fontFamily: 'Inter, sans-serif'
  }}>
    <h1 style={{ color: '#1976d2', margin: 0 }}>🚀 Escrow Service Platform</h1>
    <p style={{ color: '#666', margin: 0, textAlign: 'center', maxWidth: '600px' }}>
      Your React + Vite + TypeScript application is ready for development!
      <br />
      Start building your escrow service components.
    </p>
    <div style={{
      background: '#f5f5f5',
      padding: '20px',
      borderRadius: '8px',
      border: '1px solid #ddd'
    }}>
      <h3 style={{ margin: '0 0 10px 0', color: '#333' }}>✅ Vite Setup Complete</h3>
      <ul style={{ margin: 0, paddingLeft: '20px', color: '#666' }}>
        <li>Fast HMR (Hot Module Replacement)</li>
        <li>TypeScript support</li>
        <li>Material-UI ready</li>
        <li>Redux Toolkit configured</li>
        <li>React Query integrated</li>
        <li>Path aliases configured</li>
      </ul>
    </div>
    <small style={{ color: '#999' }}>
      Environment: {import.meta.env.MODE} | 
      Dev: {import.meta.env.DEV ? 'Yes' : 'No'}
    </small>
  </div>
)

// Create React Query client
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      cacheTime: 10 * 60 * 1000, // 10 minutes
      retry: (failureCount, error) => {
        // Don't retry on 4xx errors except 408, 429
        if (error instanceof Error && 'status' in error) {
          const status = (error as any).status
          if (status >= 400 && status < 500 && ![408, 429].includes(status)) {
            return false
          }
        }
        return failureCount < 3
      },
      refetchOnWindowFocus: false,
    },
    mutations: {
      retry: false,
    },
  },
})

// Get the root element
const rootElement = document.getElementById('root')
if (!rootElement) throw new Error('Root element not found')

// Create root and render app
const root = ReactDOM.createRoot(rootElement)

root.render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        {/* Provider will be uncommented when store is created */}
        {/* <Provider store={store}> */}
          {/* ThemeProvider will be uncommented when theme is created */}
          {/* <ThemeProvider theme={theme}> */}
            <CssBaseline />
            <TempApp />
            <ToastContainer
              position="top-right"
              autoClose={5000}
              hideProgressBar={false}
              newestOnTop={false}
              closeOnClick
              rtl={false}
              pauseOnFocusLoss
              draggable
              pauseOnHover
              theme="light"
            />
          {/* </ThemeProvider> */}
        {/* </Provider> */}
      </BrowserRouter>
      {import.meta.env.DEV && <ReactQueryDevtools initialIsOpen={false} />}
    </QueryClientProvider>
  </React.StrictMode>
)

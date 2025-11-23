'use client'

import { ViewportHeightFix } from '@/components/ViewportHeightFix'

export default function LogosPage() {
  const logos = [
    // The perfect DraftRoom Studios logo
    {
      id: 1,
      name: "DraftRoom Studios",
      component: (
        <div className="flex items-center gap-4">
          <div className="relative w-12 h-12">
            <div
              className="absolute w-10 h-6 bg-gray-200 border-2 border-gray-900"
              style={{
                top: '8px',
                left: '4px',
                transform: 'perspective(100px) rotateX(20deg)'
              }}
            ></div>
            <div
              className="absolute w-8 h-1 bg-yellow-600"
              style={{ top: '12px', left: '5px' }}
            ></div>
            <div
              className="absolute w-6 h-4 bg-white border border-gray-400"
              style={{ top: '10px', left: '6px' }}
            ></div>
            <div className="absolute w-1 h-4 bg-gray-600" style={{ bottom: '0px', left: '6px' }}></div>
            <div className="absolute w-1 h-4 bg-gray-600" style={{ bottom: '0px', right: '6px' }}></div>
          </div>
          <div>
            <div className="font-inter text-xl text-gray-900">
              <span className="font-black">Draft</span><span className="font-light">Room</span>
              <span className="font-semibold ml-1">Studios</span>
            </div>
            <div className="font-inter font-light text-sm text-gray-500 tracking-widest">
              LLC
            </div>
          </div>
        </div>
      )
    }
  ]

  return (
    <>
      <ViewportHeightFix />
      <div className="min-h-screen bg-white">
        <div className="max-w-5xl mx-auto p-8">
          <div className="text-center mb-12">
            <h1 className="text-3xl font-bold text-gray-900 mb-4">DraftRoom Studios</h1>
            <p className="text-gray-600">The perfect logo design</p>
            <p className="text-sm text-gray-500 mt-2">Draft (black) + Room (light) + Studios (semibold)</p>
          </div>

          <div className="flex justify-center">
            <div className="border border-gray-200 rounded-lg p-12 shadow-lg">
              <div className="flex items-center justify-center h-32 mb-6">
                {logos[0].component}
              </div>
              <p className="text-center text-lg text-gray-800 font-medium">{logos[0].name}</p>
            </div>
          </div>

          <div className="mt-16 text-center">
            <div className="inline-flex items-center space-x-4 text-sm text-gray-500">
              <div className="flex items-center space-x-2">
                <div className="w-4 h-4 bg-gray-900 rounded"></div>
                <span>Text #1a1a1a</span>
              </div>
              <div className="flex items-center space-x-2">
                <div className="w-4 h-4 bg-gray-600 rounded"></div>
                <span>Table Legs #666666</span>
              </div>
              <div className="flex items-center space-x-2">
                <div className="w-4 h-4 bg-gray-400 rounded"></div>
                <span>Paper Border #999999</span>
              </div>
              <div className="flex items-center space-x-2">
                <div className="w-4 h-4 bg-yellow-600 rounded"></div>
                <span>T-Square #ca8a04</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  )
}
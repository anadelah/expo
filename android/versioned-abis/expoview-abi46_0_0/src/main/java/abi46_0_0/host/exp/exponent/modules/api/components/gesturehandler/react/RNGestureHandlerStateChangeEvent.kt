// 1. RCTEventEmitter was deprecated in favor of RCTModernEventEmitter interface
// 2. Event#init() with only viewTag was deprecated in favor of two arg c-tor
// 3. Event#receiveEvent() with 3 args was deprecated in favor of 4 args version
// ref: https://github.com/facebook/react-native/commit/2fbbdbb2ce897e8da3f471b08b93f167d566db1d
@file:Suppress("DEPRECATION")

package abi46_0_0.host.exp.exponent.modules.api.components.gesturehandler.react

import androidx.core.util.Pools
import abi46_0_0.com.facebook.react.bridge.Arguments
import abi46_0_0.com.facebook.react.bridge.WritableMap
import abi46_0_0.com.facebook.react.uimanager.events.Event
import abi46_0_0.com.facebook.react.uimanager.events.RCTEventEmitter
import abi46_0_0.host.exp.exponent.modules.api.components.gesturehandler.GestureHandler

class RNGestureHandlerStateChangeEvent private constructor() : Event<RNGestureHandlerStateChangeEvent>() {
  private var extraData: WritableMap? = null
  private fun <T : GestureHandler<T>> init(
    handler: T,
    newState: Int,
    oldState: Int,
    dataExtractor: RNGestureHandlerEventDataExtractor<T>?,
  ) {
    super.init(handler.view!!.id)
    extraData = createEventData(handler, dataExtractor, newState, oldState)
  }

  override fun onDispose() {
    extraData = null
    EVENTS_POOL.release(this)
  }

  override fun getEventName() = EVENT_NAME

  // TODO: coalescing
  override fun canCoalesce() = false

  // TODO: coalescing
  override fun getCoalescingKey(): Short = 0

  override fun dispatch(rctEventEmitter: RCTEventEmitter) {
    rctEventEmitter.receiveEvent(viewTag, EVENT_NAME, extraData)
  }

  companion object {
    const val EVENT_NAME = "onGestureHandlerStateChange"
    private const val TOUCH_EVENTS_POOL_SIZE = 7 // magic
    private val EVENTS_POOL = Pools.SynchronizedPool<RNGestureHandlerStateChangeEvent>(TOUCH_EVENTS_POOL_SIZE)

    fun <T : GestureHandler<T>> obtain(
      handler: T,
      newState: Int,
      oldState: Int,
      dataExtractor: RNGestureHandlerEventDataExtractor<T>?,
    ): RNGestureHandlerStateChangeEvent =
      (EVENTS_POOL.acquire() ?: RNGestureHandlerStateChangeEvent()).apply {
        init(handler, newState, oldState, dataExtractor)
      }

    fun <T : GestureHandler<T>> createEventData(
      handler: T,
      dataExtractor: RNGestureHandlerEventDataExtractor<T>?,
      newState: Int,
      oldState: Int,
    ): WritableMap = Arguments.createMap().apply {
      dataExtractor?.extractEventData(handler, this)
      putInt("handlerTag", handler.tag)
      putInt("state", newState)
      putInt("oldState", oldState)
    }
  }
}
